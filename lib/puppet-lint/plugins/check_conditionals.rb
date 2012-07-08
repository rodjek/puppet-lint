class PuppetLint::Plugins::CheckConditionals < PuppetLint::CheckPlugin
  check 'selector_inside_resource' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]].reject { |r|
        [:COMMENT, :MLCOMMENT, :WHITESPACE, :INDENT].include? r.type
      }

      resource_tokens.each_index do |resource_token_idx|
        if resource_tokens[resource_token_idx].type == :FARROW
          if resource_tokens[resource_token_idx + 1].type == :VARIABLE
            unless resource_tokens[resource_token_idx + 2].nil?
              if resource_tokens[resource_token_idx + 2].type == :QMARK
                notify :warning, {
                  :message    => 'selector inside resource block',
                  :linenumber => resource_tokens[resource_token_idx].line,
                  :column     => resource_tokens[resource_token_idx].column,
                }
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
        notify :warning, :message =>  "case statement without a default case", :linenumber => case_tokens.first.last[:line]
      end
    end
  end
end
