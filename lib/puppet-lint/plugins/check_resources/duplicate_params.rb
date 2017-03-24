# Public: Check the tokens of each resource instance for any duplicate
# parameters and record a warning for each instance found.
#
# No style guide reference
PuppetLint.new_check(:duplicate_params) do
  def check
    resource_indexes.each do |resource|
      seen_params = {}
      level = 0

      resource[:tokens].each_with_index do |token, idx|
        case token.type
        when :LBRACE
          level += 1
          next
        when :RBRACE
          seen_params.delete(level)
          level -= 1
          next
        when :FARROW
          prev_token = token.prev_code_token
          next unless prev_token.type == :NAME

          if (seen_params[level] ||= Set.new).include?(prev_token.value)
            notify :error, {
              :message => 'duplicate parameter found in resource',
              :line    => prev_token.line,
              :column  => prev_token.column,
            }
          else
            seen_params[level] << prev_token.value
          end
        end
      end
    end
  end
end
