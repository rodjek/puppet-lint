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

    # Internal: Initialise a new PuppetLint::LexerError object.
    #
    # line_no - The Integer line number of the location of the error.
    # column  - The Integer column number of the location of the error.
    def initialize(line_no, column)
      @line_no = line_no
      @column = column
    end
  end

  # Internal: The puppet-lint lexer. Converts your manifest into its tokenised
  # form.
  class Lexer
    def initialize
      @line_no = 1
      @column = 1
    end

    # Internal: A Hash whose keys are Strings representing reserved keywords in
    # the Puppet DSL.
    KEYWORDS = {
      'class'    => true,
      'case'     => true,
      'default'  => true,
      'define'   => true,
      'import'   => true,
      'if'       => true,
      'else'     => true,
      'elsif'    => true,
      'inherits' => true,
      'node'     => true,
      'and'      => true,
      'or'       => true,
      'undef'    => true,
      'true'     => true,
      'false'    => true,
      'in'       => true,
      'unless'   => true,
    }

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
    }

    # Internal: An Array of Arrays containing tokens that can be described by
    # a single regular expression.  Each sub-Array contains 2 elements, the
    # name of the token as a Symbol and a regular expression describing the
    # value of the token.
    KNOWN_TOKENS = [
      [:TYPE, /\A(Integer|Float|Boolean|Regexp|String|Array|Hash|Resource|Class|Collection|Scalar|Numeric|CatalogEntry|Data|Tuple|Struct|Optional|NotUndef|Variant|Enum|Pattern|Any|Callable|Type|Runtime|Undef|Default)/],
      [:CLASSREF, /\A(((::){0,1}[A-Z][-\w]*)+)/],
      [:NUMBER, /\A\b((?:0[xX][0-9A-Fa-f]+|0?\d+(?:\.\d+)?(?:[eE]-?\d+)?))\b/],
      [:NAME, /\A(((::)?[a-z0-9][-\w]*)(::[a-z0-9][-\w]*)*)/],
      [:LBRACK, /\A(\[)/],
      [:RBRACK, /\A(\])/],
      [:LBRACE, /\A(\{)/],
      [:RBRACE, /\A(\})/],
      [:LPAREN, /\A(\()/],
      [:RPAREN, /\A(\))/],
      [:ISEQUAL, /\A(==)/],
      [:MATCH, /\A(=~)/],
      [:FARROW, /\A(=>)/],
      [:EQUALS, /\A(=)/],
      [:APPENDS, /\A(\+=)/],
      [:PARROW, /\A(\+>)/],
      [:PLUS, /\A(\+)/],
      [:GREATEREQUAL, /\A(>=)/],
      [:RSHIFT, /\A(>>)/],
      [:GREATERTHAN, /\A(>)/],
      [:LESSEQUAL, /\A(<=)/],
      [:LLCOLLECT, /\A(<<\|)/],
      [:OUT_EDGE, /\A(<-)/],
      [:OUT_EDGE_SUB, /\A(<~)/],
      [:LCOLLECT, /\A(<\|)/],
      [:LSHIFT, /\A(<<)/],
      [:LESSTHAN, /\A(<)/],
      [:NOMATCH, /\A(!~)/],
      [:NOTEQUAL, /\A(!=)/],
      [:NOT, /\A(!)/],
      [:RRCOLLECT, /\A(\|>>)/],
      [:RCOLLECT, /\A(\|>)/],
      [:IN_EDGE, /\A(->)/],
      [:IN_EDGE_SUB, /\A(~>)/],
      [:MINUS, /\A(-)/],
      [:COMMA, /\A(,)/],
      [:DOT, /\A(\.)/],
      [:COLON, /\A(:)/],
      [:AT, /\A(@)/],
      [:SEMIC, /\A(;)/],
      [:QMARK, /\A(\?)/],
      [:BACKSLASH, /\A(\\)/],
      [:TIMES, /\A(\*)/],
      [:MODULO, /\A(%)/],
      [:PIPE, /\A(\|)/],
    ]

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
    }

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
          if value = chunk[regex, 1]
            length = value.size
            if type == :NAME
              if KEYWORDS.include? value
                tokens << new_token(value.upcase.to_sym, value, length)
              else
                tokens << new_token(type, value, length)
              end
            else
              tokens << new_token(type, value, length)
            end
            i += length
            found = true
            break
          end
        end

        unless found
          if var_name = chunk[/\A\$((::)?([\w-]+::)*[\w-]+(\[.+?\])*)/, 1]
            length = var_name.size + 1
            tokens << new_token(:VARIABLE, var_name, length)

          elsif chunk.match(/\A'(.*?)'/m)
            str_content = StringScanner.new(code[i+1..-1]).scan_until(/(\A|[^\\])(\\\\)*'/m)
            length = str_content.size + 1
            tokens << new_token(:SSTRING, str_content[0..-2], length)

          elsif chunk.match(/\A"/)
            str_contents = StringScanner.new(code[i+1..-1]).scan_until(/(\A|[^\\])(\\\\)*"/m)
            _ = code[0..i].split("\n")
            interpolate_string(str_contents, _.count, _.last.length)
            length = str_contents.size + 1

          elsif comment = chunk[/\A(#.*)/, 1]
            length = comment.size
            comment.sub!(/#/, '')
            tokens << new_token(:COMMENT, comment, length)

          elsif slash_comment = chunk[/\A(\/\/.*)/, 1]
            length = slash_comment.size
            slash_comment.sub!(/\/\//, '')
            tokens << new_token(:SLASH_COMMENT, slash_comment, length)

          elsif mlcomment = chunk[/\A(\/\*.*?\*\/)/m, 1]
            length = mlcomment.size
            mlcomment_raw = mlcomment.dup
            mlcomment.sub!(/\A\/\* ?/, '')
            mlcomment.sub!(/ ?\*\/\Z/, '')
            mlcomment.gsub!(/^ *\*/, '')
            tokens << new_token(:MLCOMMENT, mlcomment, length)
            tokens.last.raw = mlcomment_raw

          elsif chunk.match(/\A\/.*?\//) && possible_regex?
            str_content = StringScanner.new(code[i+1..-1]).scan_until(/(\A|[^\\])(\\\\)*\//m)
            length = str_content.size + 1
            tokens << new_token(:REGEX, str_content[0..-2], length)

          elsif eolindent = chunk[/\A((\r\n|\r|\n)[ \t]+)/m, 1]
            eol = eolindent[/\A([\r\n]+)/m, 1]
            indent = eolindent[/\A[\r\n]+([ \t]+)/m, 1]
            tokens << new_token(:NEWLINE, eol, eol.size)
            tokens << new_token(:INDENT, indent, indent.size)
            length = indent.size + eol.size

          elsif whitespace = chunk[/\A([ \t]+)/, 1]
            length = whitespace.size
            tokens << new_token(:WHITESPACE, whitespace, length)

          elsif eol = chunk[/\A(\r\n|\r|\n)/, 1]
            length = eol.size
            tokens << new_token(:NEWLINE, eol, length)

          elsif chunk.match(/\A\//)
            length = 1
            tokens << new_token(:DIV, '/', length)

          else
            raise PuppetLint::LexerError.new(@line_no, @column)
          end

          i += length
        end
      end

      tokens
    end

    # Internal: Given the tokens already processed, determine if the next token
    # could be a regular expression.
    #
    # Returns true if the next token could be a regex, otherwise return false.
    def possible_regex?
      prev_token = tokens.reject { |r|
        FORMATTING_TOKENS.include? r.type
      }.last

      return true if prev_token.nil?

      if REGEX_PREV_TOKENS.include? prev_token.type
        true
      else
        false
      end
    end

    # Internal: Create a new PuppetLint::Lexer::Token object, calculate its
    # line number and column and then add it to the Linked List of tokens.
    #
    # type   - The Symbol token type.
    # value  - The token value.
    # length - The Integer length of the token's value.
    # opts   - A Hash of additional values required to determine line number and
    #         column:
    #   :line   - The Integer line number if calculated externally.
    #   :column - The Integer column number if calculated externally.
    #
    # Returns the instantiated PuppetLint::Lexer::Token object.
    def new_token(type, value, length, opts = {})
      column = opts[:column] || @column
      line_no = opts[:line] || @line_no

      token = Token.new(type, value, line_no, column)
      unless tokens.last.nil?
        token.prev_token = tokens.last
        tokens.last.next_token = token

        unless FORMATTING_TOKENS.include?(token.type)
          prev_nf_idx = tokens.rindex { |r| ! FORMATTING_TOKENS.include? r.type }
          unless prev_nf_idx.nil?
            prev_nf_token = tokens[prev_nf_idx]
            prev_nf_token.next_code_token = token
            token.prev_code_token = prev_nf_token
          end
        end
      end

      @column += length
      if type == :NEWLINE
        @line_no += 1
        @column = 1
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
      str = string.scan_until(/([^\\]|^|[^\\])([\\]{2})*[#{terminators}]+/)
      begin
        [str[0..-2], str[-1,1]]
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
        if terminator == "\""
          if first
            tokens << new_token(:STRING, value, value.size + 2, :line => line, :column => column)
            first = false
          else
            line += value.scan(/(\r\n|\r|\n)/).size
            token_column = column + (ss.pos - value.size)
            tokens << new_token(:DQPOST, value, value.size + 1, :line => line, :column => token_column)
          end
        else
          if first
            tokens << new_token(:DQPRE, value, value.size + 1, :line => line, :column => column)
            first = false
          else
            line += value.scan(/(\r\n|\r|\n)/).size
            token_column = column + (ss.pos - value.size)
            tokens << new_token(:DQMID, value, value.size, :line => line, :column => token_column)
          end
          if ss.scan(/\{/).nil?
            var_name = ss.scan(/(::)?([\w-]+::)*[\w-]+/)
            if var_name.nil?
              token_column = column + ss.pos - 1
              tokens << new_token(:DQMID, "$", 1, :line => line, :column => token_column)
            else
              token_column = column + (ss.pos - var_name.size)
              tokens << new_token(:UNENC_VARIABLE, var_name, var_name.size, :line => line, :column => token_column)
            end
          else
            contents = ss.scan_until(/\}/)[0..-2]
            if contents.match(/\A(::)?([\w-]+::)*[\w-]+(\[.+?\])*/)
              contents = "$#{contents}"
            end
            lexer = PuppetLint::Lexer.new
            lexer.tokenise(contents)
            lexer.tokens.each do |token|
              tok_col = column + token.column + (ss.pos - contents.size - 1)
              tok_line = token.line + line - 1
              tokens << new_token(token.type, token.value, token.value.size, :line => tok_line, :column => tok_col)
            end
          end
        end
        value, terminator = get_string_segment(ss, '"$')
      end
    end
  end
end
