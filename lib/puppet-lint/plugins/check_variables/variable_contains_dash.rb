# Public: Test the manifest tokens for variables that contain a dash and
# record a warning for each instance found.
#
# No style guide reference
VARIABLE_DASH_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

PuppetLint.new_check(:variable_contains_dash) do
  def check
    invalid_tokens = tokens.select do |token|
      VARIABLE_DASH_TYPES.include?(token.type)
    end

    invalid_tokens.each do |token|
      next unless token.value.gsub(%r{\[.+?\]}, '').include?('-')

      notify(
        :warning,
        message: 'variable contains a dash',
        line: token.line,
        column: token.column,
        description: 'Test the manifest tokens for variables that contain a dash and record a warning for each instance found.',
        help_uri: nil,
      )
    end
  end
end
