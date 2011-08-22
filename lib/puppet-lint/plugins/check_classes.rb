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
      if tokens[token_idx].first == :CLASS
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
