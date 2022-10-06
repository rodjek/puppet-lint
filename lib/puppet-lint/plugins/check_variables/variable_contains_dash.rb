# Public: Test the manifest tokens for variables that contain a dash and
# record a warning for each instance found.
#
# No style guide reference
PuppetLint.new_check(:variable_contains_dash) do
  VARIABLE_DASH_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  def check
    invalid_tokens = tokens.select do |token|
      VARIABLE_DASH_TYPES.include?(token.type)
    end

    invalid_tokens.each do |token|
      next unless %r{-}.match?(token.value.gsub(%r{\[.+?\]}, ''))

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
