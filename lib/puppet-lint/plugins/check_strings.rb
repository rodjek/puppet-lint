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
        warn "double quoted string containing no variables on line #{token.last[:line]}"
      end

      if token.first == :DQPRE and token.last[:value] == ""
        if tokens[token_idx + 1].first == :VARIABLE
          if tokens[token_idx + 2].first == :DQPOST and tokens[token_idx + 2].last[:value] == ""
            warn "string containing only a variable on line #{tokens[token_idx + 1].last[:line]}"
          end
        end
      end

      if token.first == :DQPRE
        end_of_string_idx = tokens[token_idx..-1].index { |r| r.first == :DQPOST }
        tokens[token_idx..end_of_string_idx].each do |t|
          if t.first == :VARIABLE
            line = data.split("\n")[t.last[:line] - 1]
            if line.is_a? String and line.include? "$#{t.last[:value]}"
              warn "variable not enclosed in {} on line #{t.last[:line]}"
            end
          end
        end
      end

      if token.first == :SSTRING
        contents = token.last[:value]
        line_no = token.last[:line]

        if contents.include? '${'
          error "single quoted string containing a variable found on line #{token.last[:line]}"
        end
      end
    end
  end
end
