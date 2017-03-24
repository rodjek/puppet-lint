# Public: Test the manifest tokens for variables that contain a dash and
# record a warning for each instance found.
#
# No style guide reference
PuppetLint.new_check(:variable_contains_dash) do
  VARIABLE_DASH_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  def check
    tokens.select { |r|
      VARIABLE_DASH_TYPES.include? r.type
    }.each do |token|
      if token.value.gsub(/\[.+?\]/, '').match(/-/)
        notify :warning, {
          :message => 'variable contains a dash',
          :line    => token.line,
          :column  => token.column,
        }
      end
    end
  end
end
