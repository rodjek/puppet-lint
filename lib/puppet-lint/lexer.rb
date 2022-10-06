# encoding: utf-8

require 'pp'
require 'strscan'
require 'set'
require 'puppet-lint/lexer/token'
require 'puppet-lint/lexer/string_slurper'

# Internal: A generic error thrown by the lexer when it encounters something
# it can't handle.
class PuppetLint::LexerError < StandardError
  # Internal: Get the Integer line number of the location of the error.
  attr_reader :line_no

  # Internal: Get the Integer column number of the location of the error.
  attr_reader :column

  # Internal: Get the String reason for the error (if known).
  attr_reader :reason

  # Internal: Initialise a new PuppetLint::LexerError object.
  #
  # line_no - The Integer line number of the location of the error.
  # column  - The Integer column number of the location of the error.
  # reason  - A String describing the cause of the error (if known).
  # rubocop:disable Lint/MissingSuper
  def initialize(line_no, column, reason = nil)
    @line_no = line_no
    @column = column
    @reason = reason
  end

  def to_s
    "PuppetLint::LexerError: Line:#{line_no} Column: #{column} Reason: #{reason}"
  end
end

# Internal: The puppet-lint lexer. Converts your manifest into its tokenised
# form.
class PuppetLint::Lexer
  def initialize
    @line_no = 1
    @column = 1
  end

  def self.heredoc_queue
    @heredoc_queue ||= []
  end

  def heredoc_queue
    self.class.heredoc_queue
  end

  # Internal: A Hash whose keys are Strings representing reserved keywords in
  # the Puppet DSL.
  # From https://github.com/puppetlabs/puppet/blob/master/lib/puppet/pops/parser/lexer2.rb#L116-L137
  # or thereabouts
  KEYWORDS = {
    'case'     => true,
    'class'    => true,
    'default'  => true,
    'define'   => true,
    'import'   => true,
    'if'       => true,
    'elsif'    => true,
    'else'     => true,
    'inherits' => true,
    'node'     => true,
    'and'      => true,
    'or'       => true,
    'undef'    => true,
    'false'    => true,
    'true'     => true,
    'in'       => true,
    'unless'   => true,
    'function' => true,
    'type'     => true,
    'attr'     => true,
    'private'  => true,
  }.freeze

  # Internal: A Hash whose keys are Strings representing reserved keywords in
  # the Puppet DSL when Application Management is enabled
  # From https://github.com/puppetlabs/puppet/blob/master/lib/puppet/pops/parser/lexer2.rb#L142-L159
  # or therabouts
  # Currently unused
  APP_MANAGEMENT_TOKENS = {
    'application' => true,
    'consumes'    => true,
    'produces'    => true,
    'site'        => true,
  }.freeze

  # Internal: A Hash whose keys are Symbols representing token types which
  # a regular expression can follow.
  REGEX_PREV_TOKENS = {
    NODE: true,
    LBRACE: true,
    RBRACE: true,
    MATCH: true,
    NOMATCH: true,
    COMMA: true,
    LBRACK: true,
    IF: true,
    ELSIF: true,
    LPAREN: true,
    EQUALS: true,
  }.freeze

  # Internal: some commonly used regular expressions
  # \t == tab
  # \v == vertical tab
  # \f == form feed
  # \p{Zs} == ASCII + Unicode non-linebreaking whitespace
  WHITESPACE_RE = RUBY_VERSION == '1.8.7' ? %r{[\t\v\f ]} : %r{[\t\v\f\p{Zs}]}

  LINE_END_RE = %r{(?:\r\n|\r|\n)}.freeze

  NAME_RE = %r{\A((?:(?:::)?[_a-z0-9][-\w]*)(?:::[a-z0-9][-\w]*)*)}.freeze

  # Internal: An Array of Arrays containing tokens that can be described by
  # a single regular expression.  Each sub-Array contains 2 elements, the
  # name of the token as a Symbol and a regular expression describing the
  # value of the token.
  KNOWN_TOKENS = [
    [:WHITESPACE, %r{\A(#{WHITESPACE_RE}+)}],
    # FIXME: Future breaking change, the following :TYPE tokens conflict with
    #        the :TYPE keyword token.
    [:TYPE, %r{\A(Integer|Float|Boolean|Regexp|String|Array|Hash|Resource|Class|Collection|Scalar|Numeric|CatalogEntry|Data|Tuple|Struct|Optional|NotUndef|Variant|Enum|Pattern|Any|Callable|Type|Runtime|Undef|Default|Sensitive)\b}], # rubocop:disable Layout/LineLength
    [:CLASSREF, %r{\A(((::){0,1}[A-Z][-\w]*)+)}],
    [:NUMBER, %r{\A\b((?:0[xX][0-9A-Fa-f]+|0?\d+(?:\.\d+)?(?:[eE]-?\d+)?))\b}],
    [:FUNCTION_NAME, %r{#{NAME_RE}(?=\()}],
    [:NAME, NAME_RE],
    [:LBRACK, %r{\A(\[)}],
    [:RBRACK, %r{\A(\])}],
    [:LBRACE, %r{\A(\{)}],
    [:RBRACE, %r{\A(\})}],
    [:LPAREN, %r{\A(\()}],
    [:RPAREN, %r{\A(\))}],
    [:ISEQUAL, %r{\A(==)}],
    [:MATCH, %r{\A(=~)}],
    [:FARROW, %r{\A(=>)}],
    [:EQUALS, %r{\A(=)}],
    [:APPENDS, %r{\A(\+=)}],
    [:PARROW, %r{\A(\+>)}],
    [:PLUS, %r{\A(\+)}],
    [:GREATEREQUAL, %r{\A(>=)}],
    [:RSHIFT, %r{\A(>>)}],
    [:GREATERTHAN, %r{\A(>)}],
    [:LESSEQUAL, %r{\A(<=)}],
    [:LLCOLLECT, %r{\A(<<\|)}],
    [:OUT_EDGE, %r{\A(<-)}],
    [:OUT_EDGE_SUB, %r{\A(<~)}],
    [:LCOLLECT, %r{\A(<\|)}],
    [:LSHIFT, %r{\A(<<)}],
    [:LESSTHAN, %r{\A(<)}],
    [:NOMATCH, %r{\A(!~)}],
    [:NOTEQUAL, %r{\A(!=)}],
    [:NOT, %r{\A(!)}],
    [:RRCOLLECT, %r{\A(\|>>)}],
    [:RCOLLECT, %r{\A(\|>)}],
    [:IN_EDGE, %r{\A(->)}],
    [:IN_EDGE_SUB, %r{\A(~>)}],
    [:MINUS, %r{\A(-)}],
    [:COMMA, %r{\A(,)}],
    [:DOT, %r{\A(\.)}],
    [:COLON, %r{\A(:)}],
    [:SEMIC, %r{\A(;)}],
    [:QMARK, %r{\A(\?)}],
    [:BACKSLASH, %r{\A(\\)}],
    [:TIMES, %r{\A(\*)}],
    [:MODULO, %r{\A(%)}],
    [:PIPE, %r{\A(\|)}],
  ].freeze

  # Internal: A Hash whose keys are Symbols representing token types which
  # are considered to be formatting tokens (i.e. tokens that don't contain
  # code).
  FORMATTING_TOKENS = {
    WHITESPACE: true,
    NEWLINE: true,
    COMMENT: true,
    MLCOMMENT: true,
    SLASH_COMMENT: true,
    INDENT: true,
  }.freeze

  # Internal: Access the internal token storage.
  #
  # Returns an Array of PuppetLint::Lexer::Toxen objects.
  def tokens
    @tokens ||= []
  end

  # Internal: Convert a Puppet manifest into tokens.
  #
  # code - The Puppet manifest to be tokenised as a String.
  #
  # Returns an Array of PuppetLint::Lexer::Token objects.
  # Raises PuppetLint::LexerError if it encounters unexpected characters
  # (usually the result of syntax errors).
  def tokenise(code)
    i = 0

    while i < code.size
      chunk = code[i..-1]

      found = false

      KNOWN_TOKENS.each do |type, regex|
        value = chunk[regex, 1]
        next if value.nil?

        i += value.size
        tokens << if type == :NAME && KEYWORDS.include?(value)
                    new_token(value.upcase.to_sym, value)
                  else
                    new_token(type, value)
                  end
        found = true
        break
      end

      next if found

      if (var_name = chunk[%r{\A\$((::)?(\w+(-\w+)*::)*\w+(-\w+)*(\[.+?\])*)}, 1])
        length = var_name.size + 1
        opts = if chunk.start_with?('$')
                 { raw: "$#{var_name}" }
               else
                 {}
               end
        tokens << new_token(:VARIABLE, var_name, opts)

      elsif %r{\A'.*?'}m.match?(chunk)
        str_content = StringScanner.new(code[i + 1..-1]).scan_until(%r{(\A|[^\\])(\\\\)*'}m)
        length = str_content.size + 1
        tokens << new_token(:SSTRING, str_content[0..-2])

      elsif chunk.start_with?('"')
        slurper = PuppetLint::Lexer::StringSlurper.new(code[i + 1..-1])
        begin
          string_segments = slurper.parse
          process_string_segments(string_segments)
          length = slurper.consumed_chars + 1
        rescue PuppetLint::Lexer::StringSlurper::UnterminatedStringError
          raise PuppetLint::LexerError.new(@line_no, @column, 'unterminated string')
        end

      elsif (heredoc_name = chunk[%r{\A@\(("?.+?"?(:.+?)?#{WHITESPACE_RE}*(/.*?)?)\)}o, 1])
        heredoc_queue << heredoc_name
        tokens << new_token(:HEREDOC_OPEN, heredoc_name)
        length = heredoc_name.size + 3

      elsif (comment = chunk[%r{\A(#[^\r\n]*)#{LINE_END_RE}?}o, 1])
        length = comment.size
        comment.sub!(%r{#}, '')
        tokens << new_token(:COMMENT, comment)

      elsif (slash_comment = chunk[%r{\A(//[^\r\n]*)#{LINE_END_RE}?}o, 1])
        length = slash_comment.size
        slash_comment.sub!(%r{//}, '')
        tokens << new_token(:SLASH_COMMENT, slash_comment)

      elsif (mlcomment = chunk[%r{\A(/\*.*?\*/)}m, 1])
        length = mlcomment.size
        mlcomment_raw = mlcomment.dup
        mlcomment.sub!(%r{\A/\* ?}, '')
        mlcomment.sub!(%r{ ?\*/\Z}, '')
        mlcomment.gsub!(%r{^ *\*}, '')
        tokens << new_token(:MLCOMMENT, mlcomment, raw: mlcomment_raw)

      elsif chunk.match(%r{\A/.*?/}m) && possible_regex?
        str_content = StringScanner.new(code[i + 1..-1]).scan_until(%r{(\A|[^\\])(\\\\)*/}m)
        length = str_content.size + 1
        tokens << new_token(:REGEX, str_content[0..-2])

      elsif (eolindent = chunk[%r{\A(#{LINE_END_RE}#{WHITESPACE_RE}+)}mo, 1])
        eol = eolindent[%r{\A(#{LINE_END_RE})}mo, 1]
        tokens << new_token(:NEWLINE, eol)
        length = eol.size

        if heredoc_queue.empty?
          indent = eolindent[%r{\A#{LINE_END_RE}+(#{WHITESPACE_RE}+)}mo, 1]
          tokens << new_token(:INDENT, indent)
          length += indent.size
        else
          heredoc_tag = heredoc_queue.shift
          slurper = PuppetLint::Lexer::StringSlurper.new(code[i + length..-1])
          heredoc_segments = slurper.parse_heredoc(heredoc_tag)
          process_heredoc_segments(heredoc_segments)
          length += slurper.consumed_chars
        end

      elsif (eol = chunk[%r{\A(#{LINE_END_RE})}o, 1])
        length = eol.size
        tokens << new_token(:NEWLINE, eol)

        unless heredoc_queue.empty?
          heredoc_tag = heredoc_queue.shift
          slurper = PuppetLint::Lexer::StringSlurper.new(code[i + length..-1])
          heredoc_segments = slurper.parse_heredoc(heredoc_tag)
          process_heredoc_segments(heredoc_segments)
          length += slurper.consumed_chars
        end

      elsif chunk.start_with?('/')
        length = 1
        tokens << new_token(:DIV, '/')

      elsif chunk.start_with?('@')
        length = 1
        tokens << new_token(:AT, '@')

      else
        raise PuppetLint::LexerError.new(@line_no, @column)
      end

      i += length
    end

    tokens
  end

  # Internal: Given the tokens already processed, determine if the next token
  # could be a regular expression.
  #
  # Returns true if the next token could be a regex, otherwise return false.
  def possible_regex?
    prev_token = tokens.reject { |r|
      FORMATTING_TOKENS.include?(r.type)
    }.last

    return true if prev_token.nil?

    REGEX_PREV_TOKENS.include?(prev_token.type)
  end

  # Internal: Create a new PuppetLint::Lexer::Token object, calculate its
  # line number and column and then add it to the Linked List of tokens.
  #
  # type   - The Symbol token type.
  # value  - The token value.
  # opts   - A Hash of additional values required to determine line number and
  #         column:
  #   :line   - The Integer line number if calculated externally.
  #   :column - The Integer column number if calculated externally.
  #   :raw    - The String raw value of the token (if necessary).
  #
  # Returns the instantiated PuppetLint::Lexer::Token object.
  def new_token(type, value, *args)
    # This bit of magic is used instead of an "opts = {}" argument so that we
    # can safely deprecate the old "length" parameter that might still be
    # passed by 3rd party plugins that haven't updated yet.
    opts = args.last.is_a?(Hash) ? args.last : {}

    # column number is calculated at the end of this method by calling
    # to_manifest on the token. Because the string tokens (DQPRE, DQMID etc)
    # are parsed before the variable token, they default to assuming that
    # they are followed by an enclosed variable and we need to remove 2 from
    # the column number if we encounter an unenclosed variable because of the
    # missing ${ at the end of the token value.
    @column -= 2 if type == :UNENC_VARIABLE

    column = opts[:column] || @column
    line_no = opts[:line] || @line_no

    token = Token.new(type, value, line_no, column)
    unless tokens.last.nil?
      token.prev_token = tokens.last
      tokens.last.next_token = token

      unless FORMATTING_TOKENS.include?(token.type)
        prev_nf_idx = tokens.rindex { |r| !FORMATTING_TOKENS.include?(r.type) }
        unless prev_nf_idx.nil?
          prev_nf_token = tokens[prev_nf_idx]
          prev_nf_token.next_code_token = token
          token.prev_code_token = prev_nf_token
        end
      end
    end

    token.raw = opts[:raw] if opts[:raw]

    if type == :NEWLINE
      @line_no += 1
      @column = 1
    else
      lines = token.to_manifest.split(LINE_END_RE, -1)
      @line_no += lines.length - 1
      if lines.length > 1
        # if the token renders to multiple lines, set the column state to the
        # length of the last line plus 1 (because column numbers are
        # 1 indexed)
        @column = lines.last.size + 1
      else
        @column += (lines.last || '').size
      end
    end

    token
  end

  def process_string_segments(segments)
    return if segments.empty?

    if segments.length == 1
      tokens << new_token(:STRING, segments[0][1])
      return
    end

    pre_segment = segments.delete_at(0)
    post_segment = segments.delete_at(-1)

    tokens << new_token(:DQPRE, pre_segment[1])
    segments.each do |segment|
      case segment[0]
      when :INTERP
        lexer = PuppetLint::Lexer.new
        lexer.tokenise(segment[1])
        lexer.tokens.each_with_index do |t, i|
          type = i.zero? && t.interpolated_variable? ? :VARIABLE : t.type
          tokens << new_token(type, t.value, raw: t.raw)
        end
      when :UNENC_VAR
        tokens << new_token(:UNENC_VARIABLE, segment[1].gsub(%r{\A\$}, ''))
      else
        tokens << new_token(:DQMID, segment[1])
      end
    end
    tokens << new_token(:DQPOST, post_segment[1])
  end

  def process_heredoc_segments(segments)
    return if segments.empty?

    end_tag = segments.delete_at(-1)

    if segments.length == 1
      tokens << new_token(:HEREDOC, segments[0][1], raw: "#{segments[0][1]}#{end_tag[1]}")
      return
    end

    pre_segment = segments.delete_at(0)
    post_segment = segments.delete_at(-1)

    tokens << new_token(:HEREDOC_PRE, pre_segment[1])
    segments.each do |segment|
      case segment[0]
      when :INTERP
        lexer = PuppetLint::Lexer.new
        lexer.tokenise(segment[1])
        lexer.tokens.each_with_index do |t, i|
          type = i.zero? && t.interpolated_variable? ? :VARIABLE : t.type
          tokens << new_token(type, t.value, raw: t.raw)
        end
      when :UNENC_VAR
        tokens << new_token(:UNENC_VARIABLE, segment[1].gsub(%r{\A\$}, ''))
      else
        tokens << new_token(:HEREDOC_MID, segment[1])
      end
    end
    tokens << new_token(:HEREDOC_POST, post_segment[1], raw: "#{post_segment[1]}#{end_tag[1]}")
  end
end
