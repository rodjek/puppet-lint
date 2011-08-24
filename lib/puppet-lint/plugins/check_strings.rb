require 'puppet'

class PuppetLint::Plugins::CheckStrings < PuppetLint::CheckPlugin
  class ::Puppet::Parser::Lexer
    class TokenList
      def del_token(token)
        @tokens.delete(token)
      end
    end

    TOKENS.add_tokens("<single quotes string>" => :SSTRING)
    TOKENS.del_token(:SQUOTE)

    TOKENS.add_token :SQUOTE, "'" do |lexer, value|
      [TOKENS[:SSTRING], lexer.slurpstring(value,["'"],:ignore_invalid_escapes).first ]
    end
  end

  def test(data)
    l = Puppet::Parser::Lexer.new
    l.string = data
    tokens = l.fullscan

    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :STRING
        contents = token.last[:value]
        line_no = token.last[:line]
        variable_found = false

        contents.scan(/.\$./) do |w|
          if w.start_with? '\\'
            next
          elsif w.end_with? '{'
            variable_found = true
          else
            warn "variable not enclosed in {} on line #{line_no}"
          end
        end
        unless variable_found
          warn "double quoted string containing no variables on line #{line_no}"
        end
      end

      if token.first == :SSTRING
        contents = token.last[:value]
        line_no = token.last[:line]

        if contents.include? '${'
          error "single quoted string containing a variable found on line #{line_no}"
        end
      end
    end
  end
end
