# Public: Test the manifest tokens for any selectors embedded within resource
# declarations and record a warning for each instance found.
PuppetLint.new_check(:selector_inside_resource) do
  def check
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]

      resource_tokens.each do |token|
        if token.type == :FARROW
          if token.next_code_token.type == :VARIABLE
            unless token.next_code_token.next_code_token.nil?
              if token.next_code_token.next_code_token.type == :QMARK
                notify :warning, {
                  :message    => 'selector inside resource block',
                  :linenumber => token.line,
                  :column     => token.column,
                }
              end
            end
          end
        end
      end
    end
  end
end

# Public: Test the manifest tokens for any case statements that do not
# contain a "default" case and record a warning for each instance found.
PuppetLint.new_check(:case_without_default) do
  def check
    case_indexes = []

    tokens.each_index do |token_idx|
      if tokens[token_idx].type == :CASE
        depth = 0
        tokens[(token_idx + 1)..-1].each_index do |case_token_idx|
          idx = case_token_idx + token_idx + 1
          if tokens[idx].type == :LBRACE
            depth += 1
          elsif tokens[idx].type == :RBRACE
            depth -= 1
            if depth == 0
              case_indexes << {:start => token_idx, :end => idx}
              break
            end
          end
        end
      end
    end

    case_indexes.each do |kase|
      case_tokens = tokens[kase[:start]..kase[:end]]

      unless case_tokens.index { |r| r.type == :DEFAULT }
        notify :warning, {
          :message    => 'case statement without a default case',
          :linenumber => case_tokens.first.line,
          :column     => case_tokens.first.column,
        }
      end
    end
  end
end
