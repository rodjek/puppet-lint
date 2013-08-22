class PuppetLint::Plugins::CheckNodes < PuppetLint::CheckPlugin
  # Check the manifest for unquoted node names and warn if found.
  #
  # Returns nothing.
  check 'unquoted_node_name' do
    tokens.select { |r|
      r.type == :NODE && r.next_code_token.type == :NAME
    }.each do |token|
      value_token = token.next_code_token
      unless value_token.value == 'default'
        notify :warning, {
          :message    => 'unquoted node name found',
          :linenumber => value_token.line,
          :column     => value_token.column,
        }
      end
    end
  end
end
