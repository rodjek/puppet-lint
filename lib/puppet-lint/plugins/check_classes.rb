class PuppetLint::Plugins::CheckClasses < PuppetLint::CheckPlugin
  def test(data)
    lexer = Puppet::Parser::Lexer.new
    lexer.string = data
    tokens = lexer.fullscan

    tokens.select { |r| r.first == :OUT_EDGE }.each do |token|
      warn "right-to-left (<-) relationship on line #{token.last[:line]}"
    end

    class_indexes = []
    tokens.each_index do |token_idx|
      if [:DEFINE, :CLASS].include? tokens[token_idx].first
        header_end_idx = tokens[token_idx..-1].index { |r| r.first == :LBRACE }
        lparen_idx = tokens[token_idx..(header_end_idx + token_idx)].index { |r| r.first == :LPAREN }
        rparen_idx = tokens[token_idx..(header_end_idx + token_idx)].rindex { |r| r.first == :RPAREN }

        unless lparen_idx.nil? or rparen_idx.nil?
          param_tokens = tokens[lparen_idx..rparen_idx]
          param_tokens.each_index do |param_tokens_idx|
            this_token = param_tokens[param_tokens_idx]
            next_token = param_tokens[param_tokens_idx+1]
            if this_token.first == :VARIABLE
              if next_token.first == :COMMA or next_token.first == :RPAREN
                unless param_tokens[0..param_tokens_idx].rindex { |r| r.first == :EQUALS }.nil?
                  warn "optional parameter listed before required parameter on line #{this_token.last[:line]}"
                end
              end
            end
          end
        end
      end

      if tokens[token_idx].first == :CLASS

        if tokens[token_idx+2].first == :INHERITS
          class_name = tokens[token_idx+1].last[:value]
          inherited_class = tokens[token_idx+3].last[:value]

          unless class_name =~ /^#{inherited_class}::/
            warn "class inherits across namespaces on line #{tokens[token_idx].last[:line]}"
          end
        end

        lbrace_count = 0
        tokens[token_idx+1..-1].each_index do |class_token_idx|
          idx = class_token_idx + token_idx
          if tokens[idx].first == :LBRACE
            lbrace_count += 1
          elsif tokens[idx].first == :RBRACE
            lbrace_count -= 1
            if lbrace_count == 0
              class_indexes << {:start => token_idx, :end => idx}
              break
            end
          end
        end
      end
    end

    class_indexes.each do |class_idx|
      class_tokens = tokens[class_idx[:start]..class_idx[:end]]
      class_tokens[1..-1].select { |r| r.first == :CLASS }.each do |token|
        warn "class defined inside a class on line #{token.last[:line]}"
      end
      class_tokens[1..-1].select { |r| r.first == :DEFINE }.each do |token|
        warn "define defined inside a class on line #{token.last[:line]}"
      end
    end
  end
end
