class PuppetLint::Plugins::CheckVariables < PuppetLint::CheckPlugin
  # Public: Test the manifest tokens for variables that contain a dash and
  # record a warning for each instance found.
  #
  # Returns nothing.
  check 'variable_contains_dash' do
    tokens.select { |r|
      {:VARIABLE => true, :UNENC_VARIABLE => true}.include? r.type
    }.each do |token|
      if token.value.match(/-/)
        notify :warning, {
          :message    => 'variable contains a dash',
          :linenumber => token.line,
          :column     => token.column,
        }
      end
    end
  end
end
