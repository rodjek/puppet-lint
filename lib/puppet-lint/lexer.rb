# encoding: utf-8

require 'pp'
require 'strscan'
require 'puppet-lint/lexer/token'
require 'set'

class PuppetLint
  # Internal: A generic error thrown by the lexer when it encounters something
  # it can't handle.
  class LexerError < StandardError
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
    def initialize(line_no, column, reason = nil)
      @line_no = line_no
      @column = column
      @reason = reason
    end
  end

  # Internal: The puppet-lint lexer. Converts your manifest into its tokenised
  # form.
  class Lexer # rubocop:disable Metrics/ClassLength
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
      :NODE    => true,
      :LBRACE  => true,
      :RBRACE  => true,
      :MATCH   => true,
      :NOMATCH => true,
      :COMMA   => true,
      :LBRACK  => true,
      :IF      => true,
      :ELSIF   => true,
      :LPAREN  => true,
    }.freeze

    # Internal: An Array of Arrays containing tokens that can be described by
    # a single regular expression.  Each sub-Array contains 2 elements, the
    # name of the token as a Symbol and a regular expression describing the
    # value of the token.
    NAME_RE = %r{\A(((::)?[_a-z0-9][-\w]*)(::[a-z0-9][-\w]*)*)}
    KNOWN_TOKENS = [
      [:TYPE, %r{\A(Integer|Float|Boolean|Regexp|String|Array|Hash|Resource|Class|Collection|Scalar|Numeric|CatalogEntry|Data|Tuple|Struct|Optional|NotUndef|Variant|Enum|Pattern|Any|Callable|Type|Runtime|Undef|Default)\b}],
      [:CLASSREF, %r{\A(((::){0,1}[A-Z][-\w]*)+)}],
      [:NUMBER, %r{\A\b((?:0[xX][0-9A-Fa-f]+|0?\d+(?:\.\d+)?(?:[eE]-?\d+)?))\b}],
      [:FUNCTION_NAME, %r{#{NAME_RE}\(}],
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
      :WHITESPACE    => true,
      :NEWLINE       => true,
      :COMMENT       => true,
      :MLCOMMENT     => true,
      :SLASH_COMMENT => true,
      :INDENT        => true,
    }.freeze

    # \t == tab
    # \v == vertical tab
    # \f == form feed
    # \p{Zs} == ASCII + Unicode non-linebreaking whitespace
    WHITESPACE_RE = RUBY_VERSION == '1.8.7' ? %r{[\t\v\f ]} : %r{[\t\v\f\p{Zs}]}

    LINE_END_RE = %r{(?:\r\n|\r|\n)}

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

          length = value.size
          tokens << if type == :NAME && KEYWORDS.include?(value)
                      new_token(value.upcase.to_sym, value)
                    else
                      new_token(type, value)
                    end
          i += length
          found = true
          break
        end

        next if found

        if var_name = chunk[%r{\A\$((::)?(\w+(-\w+)*::)*\w+(-\w+)*(\[.+?\])*)}, 1]
          length = var_name.size + 1
          tokens << new_token(:VARIABLE, var_name)

        elsif chunk =~ %r{\A'.*?'}m
          str_content = StringScanner.new(code[i + 1..-1]).scan_until(%r{(\A|[^\\])(\\\\)*'}m)
          length = str_content.size + 1
          tokens << new_token(:SSTRING, str_content[0..-2])

        elsif chunk.start_with?('"')
          str_contents = slurp_string(code[i + 1..-1])
          lines_parsed = code[0..i].split(LINE_END_RE)
          interpolate_string(str_contents, lines_parsed.count, lines_parsed.last.length)
          length = str_contents.size + 1

        elsif heredoc_name = chunk[%r{\A@\(("?.+?"?(:.+?)?(/.*?)?)\)}, 1]
          heredoc_queue << heredoc_name
          tokens << new_token(:HEREDOC_OPEN, heredoc_name)
          length = heredoc_name.size + 3

        elsif comment = chunk[%r{\A(#[^\r\n]*)#{LINE_END_RE}?}, 1]
          length = comment.size
          comment.sub!(%r{#}, '')
          tokens << new_token(:COMMENT, comment)

        elsif slash_comment = chunk[%r{\A(//[^\r\n]*)#{LINE_END_RE}?}, 1]
          length = slash_comment.size
          slash_comment.sub!(%r{//}, '')
          tokens << new_token(:SLASH_COMMENT, slash_comment)

        elsif mlcomment = chunk[%r{\A(/\*.*?\*/)}m, 1]
          length = mlcomment.size
          mlcomment_raw = mlcomment.dup
          mlcomment.sub!(%r{\A/\* ?}, '')
          mlcomment.sub!(%r{ ?\*/\Z}, '')
          mlcomment.gsub!(%r{^ *\*}, '')
          tokens << new_token(:MLCOMMENT, mlcomment, :raw => mlcomment_raw)

        elsif chunk.match(%r{\A/.*?/}) && possible_regex?
          str_content = StringScanner.new(code[i + 1..-1]).scan_until(%r{(\A|[^\\])(\\\\)*/}m)
          length = str_content.size + 1
          tokens << new_token(:REGEX, str_content[0..-2])

        elsif eolindent = chunk[%r{\A(#{LINE_END_RE}#{WHITESPACE_RE}+)}m, 1]
          eol = eolindent[%r{\A(#{LINE_END_RE})}m, 1]
          tokens << new_token(:NEWLINE, eol)
          length = eol.size

          if heredoc_queue.empty?
            indent = eolindent[%r{\A#{LINE_END_RE}+(#{WHITESPACE_RE}+)}m, 1]
            tokens << new_token(:INDENT, indent)
            length += indent.size
          else
            heredoc_tag = heredoc_queue.shift
            heredoc_name = heredoc_tag[%r{\A"?(.+?)"?(:.+?)?(/.*)?\Z}, 1]
            str_contents = StringScanner.new(code[(i + length)..-1]).scan_until(%r{\|?\s*-?\s*#{heredoc_name}})
            interpolate_heredoc(str_contents, heredoc_tag)
            length += str_contents.size
          end

        elsif whitespace = chunk[%r{\A(#{WHITESPACE_RE}+)}, 1]
          length = whitespace.size
          tokens << new_token(:WHITESPACE, whitespace)

        elsif eol = chunk[%r{\A(#{LINE_END_RE})}, 1]
          length = eol.size
          tokens << new_token(:NEWLINE, eol)

          unless heredoc_queue.empty?
            heredoc_tag = heredoc_queue.shift
            heredoc_name = heredoc_tag[%r{\A"?(.+?)"?(:.+?)?(/.*)?\Z}, 1]
            str_contents = StringScanner.new(code[(i + length)..-1]).scan_until(%r{\|?\s*-?\s*#{heredoc_name}})
            _ = code[0..(i + length)].split(LINE_END_RE)
            interpolate_heredoc(str_contents, heredoc_tag)
            length += str_contents.size
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

    def slurp_string(string)
      dq_str_regexp = %r{(\$\{|(\A|[^\\])(\\\\)*")}m
      scanner = StringScanner.new(string)
      contents = scanner.scan_until(dq_str_regexp)

      if scanner.matched.nil?
        raise LexerError.new(@line_no, @column, 'Double quoted string missing closing quote')
      end

      until scanner.matched.end_with?('"')
        contents += scanner.scan_until(%r{\}}m)
        contents += scanner.scan_until(dq_str_regexp)
      end
      contents
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

    # Internal: Split a string on multiple terminators, excluding escaped
    # terminators.
    #
    # string      - The String to be split.
    # terminators - The String of terminators that the String should be split
    #               on.
    #
    # Returns an Array consisting of two Strings, the String up to the first
    # terminator and the terminator that was found.
    def get_string_segment(string, terminators)
      str = string.scan_until(%r{([^\\]|^|[^\\])([\\]{2})*[#{terminators}]+})
      begin
        [str[0..-2], str[-1, 1]]
      rescue
        [nil, nil]
      end
    end

    # Internal: Tokenise the contents of a double quoted string.
    #
    # string - The String to be tokenised.
    # line   - The Integer line number of the start of the passed string.
    # column - The Integer column number of the start of the passed string.
    #
    # Returns nothing.
    def interpolate_string(string, line, column)
      ss = StringScanner.new(string)
      first = true
      value, terminator = get_string_segment(ss, '"$')
      until value.nil?
        if terminator == '"'
          if first
            tokens << new_token(:STRING, value, :line => line, :column => column)
            first = false
          else
            token_column = column + (ss.pos - value.size)
            tokens << new_token(:DQPOST, value, :line => line, :column => token_column)
            line += value.scan(LINE_END_RE).size
            @column = column + ss.pos + 1
            @line_no = line
          end
        else
          if first
            tokens << new_token(:DQPRE, value, :line => line, :column => column)
            first = false
          else
            token_column = column + (ss.pos - value.size)
            tokens << new_token(:DQMID, value, :line => line, :column => token_column)
            line += value.scan(LINE_END_RE).size
          end
          if ss.scan(%r{\{}).nil?
            var_name = ss.scan(%r{(::)?(\w+(-\w+)*::)*\w+(-\w+)*})
            if var_name.nil?
              token_column = column + ss.pos - 1
              tokens << new_token(:DQMID, '$', :line => line, :column => token_column)
            else
              token_column = column + (ss.pos - var_name.size)
              tokens << new_token(:UNENC_VARIABLE, var_name, :line => line, :column => token_column)
            end
          else
            line += value.scan(LINE_END_RE).size
            contents = ss.scan_until(%r{\}})[0..-2]
            raw = contents.dup
            if contents.match(%r{\A(::)?([\w-]+::)*[\w-]+(\[.+?\])*}) && !contents.match(%r{\A\w+\(})
              contents = "$#{contents}"
            end
            lexer = PuppetLint::Lexer.new
            lexer.tokenise(contents)
            lexer.tokens.each do |token|
              tok_col = column + token.column + (ss.pos - contents.size - 1)
              tok_line = token.line + line - 1
              tokens << new_token(token.type, token.value, :line => tok_line, :column => tok_col)
            end
            if lexer.tokens.length == 1 && lexer.tokens[0].type == :VARIABLE
              tokens.last.raw = raw
            end
          end
        end
        value, terminator = get_string_segment(ss, '"$')
      end
    end

    # Internal: Tokenise the contents of a heredoc.
    #
    # string - The String to be tokenised.
    # name   - The String name/endtext of the heredoc.
    #
    # Returns nothing.
    def interpolate_heredoc(string, name)
      ss = StringScanner.new(string)
      eos_text = name[%r{\A"?(.+?)"?(:.+?)?(/.*)?\Z}, 1]
      first = true
      interpolate = name.start_with?('"')
      value, terminator = get_heredoc_segment(ss, eos_text, interpolate)
      until value.nil?
        if terminator =~ %r{\A\|?\s*-?\s*#{Regexp.escape(eos_text)}}
          if first
            tokens << new_token(:HEREDOC, value, :raw => "#{value}#{terminator}")
            first = false
          else
            tokens << new_token(:HEREDOC_POST, value, :raw => "#{value}#{terminator}")
          end
        else
          if first
            tokens << new_token(:HEREDOC_PRE, value)
            first = false
          else
            tokens << new_token(:HEREDOC_MID, value)
          end
          if ss.scan(%r{\{}).nil?
            var_name = ss.scan(%r{(::)?(\w+(-\w+)*::)*\w+(-\w+)*})
            tokens << if var_name.nil?
                        new_token(:HEREDOC_MID, '$')
                      else
                        new_token(:UNENC_VARIABLE, var_name)
                      end
          else
            contents = ss.scan_until(%r{\}})[0..-2]
            raw = contents.dup
            if contents.match(%r{\A(::)?([\w-]+::)*[\w-]|(\[.+?\])*}) && !contents.match(%r{\A\w+\(})
              contents = "$#{contents}" unless contents.start_with?('$')
            end

            lexer = PuppetLint::Lexer.new
            lexer.tokenise(contents)
            lexer.tokens.each do |token|
              tokens << new_token(token.type, token.value)
            end
            if lexer.tokens.length == 1 && lexer.tokens[0].type == :VARIABLE
              tokens.last.raw = raw
            end
          end
        end
        value, terminator = get_heredoc_segment(ss, eos_text, interpolate)
      end
    end

    # Internal: Splits a heredoc String into segments if it is to be
    # interpolated.
    #
    # string      - The String heredoc.
    # eos_text    - The String endtext for the heredoc.
    # interpolate - A Boolean that specifies whether this heredoc can contain
    #               interpolated values (defaults to True).
    #
    # Returns an Array consisting of two Strings, the String up to the first
    # terminator and the terminator that was found.
    def get_heredoc_segment(string, eos_text, interpolate = true)
      regexp = if interpolate
                 %r{(([^\\]|^|[^\\])([\\]{2})*[$]+|\|?\s*-?#{Regexp.escape(eos_text)})}
               else
                 %r{\|?\s*-?#{Regexp.escape(eos_text)}}
               end

      str = string.scan_until(regexp)
      begin
        str =~ %r{\A(.*?)([$]+|\|?\s*-?#{Regexp.escape(eos_text)})\Z}m
        [Regexp.last_match(1), Regexp.last_match(2)]
      rescue
        [nil, nil]
      end
    end
  end
end
