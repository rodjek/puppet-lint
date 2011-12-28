class PuppetLint::Plugins::CheckConditionals < PuppetLint::CheckPlugin
  check 'selector_inside_resource' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]

      resource_tokens.each_index do |resource_token_idx|
        if resource_tokens[resource_token_idx].first == :FARROW
          if resource_tokens[resource_token_idx + 1].first == :VARIABLE
            unless resource_tokens[resource_token_idx + 2].nil?
              if resource_tokens[resource_token_idx + 2].first == :QMARK
                warn "selector inside resource block on line #{resource_tokens[resource_token_idx].last[:line]}"
              end
            end
          end
        end
      end
    end
  end

  check 'case_without_default' do
    case_indexes = []

    tokens.each_index do |token_idx|
      if tokens[token_idx].first == :COLON
        # gather a list of start and end indexes for resource attribute blocks
        if tokens[token_idx+1].first != :LBRACE
          resource_indexes << {:start => token_idx+1, :end => tokens[token_idx+1..-1].index { |r| [:SEMIC, :RBRACE].include? r.first }+token_idx}
        end
      end

      if tokens[token_idx].first == :CASE
        lbrace_count = 0
        tokens[token_idx+1..-1].each_index do |case_token_idx|
          idx = case_token_idx + token_idx
          if tokens[idx].first == :LBRACE
            lbrace_count += 1
          elsif tokens[idx].first == :RBRACE
            lbrace_count -= 1
            if lbrace_count == 0
              case_indexes << {:start => token_idx, :end => idx}
              break
            end
          end
        end
      end
    end

    case_indexes.each do |kase|
      case_tokens = tokens[kase[:start]..kase[:end]]

      unless case_tokens.index { |r| r.first == :DEFAULT }
        warn "case statement without a default case on line #{case_tokens.first.last[:line]}"
      end
    end
  end
end
