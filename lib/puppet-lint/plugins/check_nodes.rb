# Public: Check the manifest for unquoted node names and record a warning for
# each instance found.
PuppetLint.new_check(:unquoted_node_name) do
  def check
    tokens.select { |r|
      r.type == :NODE && r.next_code_token.type == :NAME
    }.each do |token|
      value_token = token.next_code_token
      unless value_token.value == 'default'
        notify :warning, {
          :message => 'unquoted node name found',
          :line    => value_token.line,
          :column  => value_token.column,
          :token   => value_token,
        }
      end
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end
