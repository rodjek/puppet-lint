# Public: Test the manifest tokens for variables that contain an uppercase
# letter and record a warning for each instance found.
#
# No style guide reference
PuppetLint.new_check(:variable_is_lowercase) do
  VARIABLE_LOWERCASE_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  def check
    invalid_tokens = tokens.select do |token|
      VARIABLE_LOWERCASE_TYPES.include?(token.type)
    end

    invalid_tokens.each do |token|
      next unless %r{[A-Z]}.match?(token.value.gsub(%r{\[.+?\]}, ''))

      notify(
        :warning,
        message: 'variable contains an uppercase letter',
        line: token.line,
        column: token.column,
        description: 'Test the manifest tokens for variables that contain an uppercase letter and record a warning for each instance found.',
        help_uri: nil,
      )
    end
  end
end
