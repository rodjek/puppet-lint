# Public: Test the manifest tokens for variables that contain a dash and
# record a warning for each instance found.
PuppetLint.new_check(:variable_contains_dash) do
  def check
    tokens.select { |r|
      {:VARIABLE => true, :UNENC_VARIABLE => true}.include? r.type
    }.each do |token|
      if token.value.match(/-/)
        notify :warning, {
          :message => 'variable contains a dash',
          :line    => token.line,
          :column  => token.column,
        }
      end
    end
  end
end
