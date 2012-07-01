require 'pp'
require 'strscan'

class PuppetLint
  class Lexer
    KEYWORDS = [
      'class',
      'case',
      'default',
      'define',
      'import',
      'if',
      'else',
      'elsif',
      'inherits',
      'node',
      'and',
      'or',
      'undef',
      'true',
      'false',
      'in',
      'unless',
    ]

    KNOWN_TOKENS = [
      [:CLASSREF, /\A(((::){0,1}[A-Z][-\w]*)+)/],
      [:NUMBER, /\A(?:0[xX][0-9A-Fa-f]+|0?\d+(?:\.\d+)?(?:[eE]-?\d+)?)\b/],
      [:NAME, /\A(((::)?[a-z0-9][-\w]*)(::[a-z0-9][-\w]*)*)/],
      [:SSTRING, /\A('.*?')/],
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
      [:DIV, /\A(\/)/],
      [:TIMES, /\A(\*)/],
    ]

    def tokens
      @tokens ||= []
    end

    def tokenise(code)
      code.chomp!

      i = 0

      while i < code.size
        chunk = code[i..-1]

        found = false
        KNOWN_TOKENS.each do |type, regex|
          if value = chunk[regex, 1]
            tokens << new_token(type, value, code[0..i])
            i += value.size
            found = true
            break
          end
        end

        unless found
          if identifier = chunk[/\A([a-z]\w*)/, 1]
            if KEYWORDS.include? identifier
              type = identifier.upcase.to_sym
              tokens << new_token(type, identifier, code[0..i])
            else
              tokens << new_token(:IDENTIFIER, identifier, code[0..i])
            end
            i += identifier.size

          elsif var_name = chunk[/\A\$((::)?([\w-]+::)*[\w-]+)/, 1]
            tokens << new_token(:VARIABLE, var_name, code[0..i])
            i += var_name.size + 1
          
          elsif chunk.match(/\A"/)
            str_contents = StringScanner.new(code[i+1..-1]).scan_until(/[^\\]"/m)
            _ = code[0..i].split("\n")
            interpolate_string(str_contents, _.count, _.last.length)
            i += str_contents.size + 1

          elsif chunk.match(/\A\//)
            str_content = StringScanner.new(code[i+1..-1]).scan_until(/[^\\]\//m)
            tokens << new_token(:REGEX, str_content, code[0..i])
            i += str_content.size + 1

          elsif comment = chunk[/\A(#.*)/, 1]
            comment_size = comment.size
            comment.sub!(/# ?/, '')
            tokens << new_token(:COMMENT, comment, code[0..i])
            i += comment_size

          elsif mlcomment = chunk[/\A(\/\*.*?\*\/)/m, 1]
            mlcomment_size = mlcomment_size
            mlcomment.sub!(/^\/\* ?/, '')
            mlcomment.sub!(/ ?\*\/$/, '')
            tokens << new_token(:MLCOMMENT, mlcomment, code[0..i])
            i += mlcomment_size

          elsif indent = chunk[/\A\n(\s+)/m, 1]
            tokens << new_token(:NEWLINE, '\n', code[0..i])
            tokens << new_token(:INDENT, indent, code[0..i+1])
            i += indent.size + 1

          elsif whitespace = chunk[/\A([ \t]+)/, 1]
            tokens << new_token(:WHITESPACE, whitespace, code[0..i])
            i += whitespace.size

          elsif chunk.match(/\A\n/)
            tokens << new_token(:NEWLINE, '\n', code[0..i])
            i += 1

          else
            value = chunk[0,1]
            tokens << new_token(value, value, code[0..i])
            i += 1
          end
        end
      end

      tokens
    end

    def new_token(type, value, chunk)
      lines = chunk.split("\n")
      line_no = lines.count
      column = lines.empty? ? 1 : lines.last.length

      PuppetLint::Token.new(type, value, line_no, column)
    end

    def get_string_segment(string, terminators)
      str = string.scan_until(/([^\\]|^|[^\\])([\\]{2})*[#{terminators}]/)
      begin
        [str[0..-2], str[-1,1]]
      rescue
        [nil, nil]
      end
    end

    def interpolate_string(string, line, column)
      ss = StringScanner.new(string)
      first = true
      value, terminator = get_string_segment(ss, '"$')
      until value.nil?
        if terminator == "\""
          if first
            tokens << PuppetLint::Token.new(:STRING, value, line, column) 
            first = false
          else
            line += value.count("\n")
            token_column = column + (ss.pos - value.size)
            tokens << PuppetLint::Token.new(:DQPOST, value, line, token_column)
          end
        else
          if first
            tokens << PuppetLint::Token.new(:DQPRE, value, line, column)
            first = false
          else
            line += value.count("\n")
            token_column = column + (ss.pos - value.size)
            tokens << PuppetLint::Token.new(:DQMID, value, line, token_column)
          end
          if ss.scan(/\{/).nil?
            var_name = ss.scan(/(::)?([\w-]+::)*[\w-]+/)
            token_column = column + (ss.pos - var_name.size)
            tokens << PuppetLint::Token.new(:UNENC_VARIABLE, var_name, line, token_column)
          else
            var_name = ss.scan(/(::)?([\w-]+::)*[\w-]+/)
            token_column = column + (ss.pos - var_name.size)
            tokens << PuppetLint::Token.new(:VARIABLE, var_name, line, token_column)
            ss.scan(/\}/)
          end
        end
        value, terminator = get_string_segment(ss, '"$')
      end
    end
  end

  class Token
    attr_reader :type, :value, :line, :column

    def initialize(type, value, line, column)
      @value = value
      @type = type
      @line = line
      @column = column
    end

    def inspect
      "<Token #{@type.inspect} (#{@value}) @#{@line}:#{@column}>"
    end
  end
end
