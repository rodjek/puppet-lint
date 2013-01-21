require 'pp'
require 'strscan'
require 'puppet-lint/lexer/token'
require 'set'

class PuppetLint
  class LexerError < StandardError
    # Internal: Get the Integer line number of the location of the error.
    attr_reader :line_no

    # Internal: Get the Integer column number of the location of the error.
    attr_reader :column

    # Internal: Initialise a new PuppetLint::LexerError object.
    #
    # code   - The String manifest code being tokenised.
    # offset - The Integer position in the code string that the tokeniser was
    #          at when it encountered the error.
    def initialize(code, offset)
      chunk = code[0..offset]
      @line_no = chunk.count("\n") + 1
      if @line_no == 1
        @column = chunk.length
      else
        @column = chunk.length - chunk.rindex("\n") - 1
      end
      @column = 1 if @column == 0
    end
  end

  class Lexer
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
    }

    # Internal: An Array of Arrays containing tokens that can be described by
    # a single regular expression.  Each sub-Array contains 2 elements, the
    # name of the token as a Symbol and a regular expression describing the
    # value of the token.
    KNOWN_TOKENS = [
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
      code.chomp!

      i = 0

      while i < code.size
        chunk = code[i..-1]

        found = false

        KNOWN_TOKENS.each do |type, regex|
          if value = chunk[regex, 1]
            if type == :NAME
              if KEYWORDS.include? value
                tokens << new_token(value.upcase.to_sym, value, :chunk => code[0..i])
              else
                tokens << new_token(type, value, :chunk => code[0..i])
              end
            else
              tokens << new_token(type, value, :chunk => code[0..i])
            end
            i += value.size
            found = true
            break
          end
        end

        unless found
          if var_name = chunk[/\A\$((::)?([\w-]+::)*[\w-]+)/, 1]
            tokens << new_token(:VARIABLE, var_name, :chunk => code[0..i])
            i += var_name.size + 1

          elsif chunk.match(/\A'(.*?)'/m)
            str_content = StringScanner.new(code[i+1..-1]).scan_until(/(\A|[^\\])(\\\\)*'/m)
            tokens << new_token(:SSTRING, str_content[0..-2], :chunk => code[0..i])
            i += str_content.size + 1

          elsif chunk.match(/\A"/)
            str_contents = StringScanner.new(code[i+1..-1]).scan_until(/(\A|[^\\])(\\\\)*"/m)
            _ = code[0..i].split("\n")
            interpolate_string(str_contents, _.count, _.last.length)
            i += str_contents.size + 1

          elsif comment = chunk[/\A(#.*)/, 1]
            comment_size = comment.size
            comment.sub!(/# ?/, '')
            tokens << new_token(:COMMENT, comment, :chunk => code[0..i])
            i += comment_size

          elsif slash_comment = chunk[/\A(\/\/.*)/, 1]
            slash_comment_size = slash_comment.size
            slash_comment.sub!(/\/\/ ?/, '')
            tokens << new_token(:SLASH_COMMENT, slash_comment, :chunk => code[0..i])
            i += slash_comment_size

          elsif mlcomment = chunk[/\A(\/\*.*?\*\/)/m, 1]
            mlcomment_size = mlcomment.size
            mlcomment.sub!(/\A\/\* ?/, '')
            mlcomment.sub!(/ ?\*\/\Z/, '')
            mlcomment.gsub!(/^ ?\* ?/, '')
            mlcomment.strip!
            tokens << new_token(:MLCOMMENT, mlcomment, :chunk => code[0..i])
            i += mlcomment_size

          elsif chunk.match(/\A\/.*?\//) && possible_regex?
            str_content = StringScanner.new(code[i+1..-1]).scan_until(/(\A|[^\\])(\\\\)*\//m)
            tokens << new_token(:REGEX, str_content[0..-2], :chunk => code[0..i])
            i += str_content.size + 1

          elsif indent = chunk[/\A\r?\n([ \t]+)/m, 1]
            tokens << new_token(:NEWLINE, '\n', :chunk => code[0..i])
            tokens << new_token(:INDENT, indent, :chunk => code[0..i+1])
            i += indent.size + 1

          elsif whitespace = chunk[/\A([ \t]+)/, 1]
            tokens << new_token(:WHITESPACE, whitespace, :chunk => code[0..i])
            i += whitespace.size

          elsif chunk.match(/\A\r?\n/)
            tokens << new_token(:NEWLINE, '\n', :chunk => code[0..i])
            i += 1

          elsif chunk.match(/\A\//)
            tokens << new_token(:DIV, '/', :chunk => code[0..i])
            i += 1

          else
            raise PuppetLint::LexerError.new(code, i)
          end
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
    # type  - The Symbol token type.
    # value - The token value.
    # opts  - A Hash of additional values required to determine line number and
    #         column:
    #   :chunk  - The String chunk of the manifest that has been tokenised so
    #             far.
    #   :line   - The Integer line number if calculated externally.
    #   :column - The Integer column number if calculated externally.
    #
    # Returns the instantiated PuppetLint::Lexer::Token object.
    def new_token(type, value, opts = {})
      if opts[:chunk]
        line_no = opts[:chunk].count("\n") + 1
        if line_no == 1
          column = opts[:chunk].length
        else
          column = opts[:chunk].length - opts[:chunk].rindex("\n") - 1
        end
        column += 1 if column == 0
      else
        column = opts[:column]
        line_no = opts[:line]
      end

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
            tokens << new_token(:STRING, value, :line => line, :column => column)
            first = false
          else
            line += value.count("\n")
            token_column = column + (ss.pos - value.size)
            tokens << new_token(:DQPOST, value, :line => line, :column => token_column)
          end
        else
          if first
            tokens << new_token(:DQPRE, value, :line => line, :column => column)
            first = false
          else
            line += value.count("\n")
            token_column = column + (ss.pos - value.size)
            tokens << new_token(:DQMID, value, :line => line, :column => token_column)
          end
          if ss.scan(/\{/).nil?
            var_name = ss.scan(/(::)?([\w-]+::)*[\w-]+/)
            unless var_name.nil?
              token_column = column + (ss.pos - var_name.size)
              tokens << new_token(:UNENC_VARIABLE, var_name, :line => line, :column => token_column)
            end
          else
            contents = ss.scan_until(/\}/)[0..-2]
            if contents.match(/\A(::)?([\w-]+::)*[\w-]+\Z/)
              token_column = column + (ss.pos - contents.size - 1)
              tokens << new_token(:VARIABLE, contents, :line => line, :column => token_column)
            else
              lexer = PuppetLint::Lexer.new
              lexer.tokenise(contents)
              lexer.tokens.each do |token|
                tok_col = column + token.column + (ss.pos - contents.size - 1)
                tok_line = token.line + line - 1
                tokens << new_token(token.type, token.value, :line => tok_line, :column => tok_col)
              end
            end
          end
        end
        value, terminator = get_string_segment(ss, '"$')
      end
    end
  end
end
