# Public: Check the manifest tokens for any double or single quoted strings
# containing only a boolean value and record a warning for each instance
# found.
#
# No style guide reference
PuppetLint.new_check(:quoted_booleans) do
  STRING_TYPES = Set[:STRING, :SSTRING]
  BOOLEANS = Set['true', 'false']

  def check
    invalid_tokens = tokens.select do |token|
      STRING_TYPES.include?(token.type) && BOOLEANS.include?(token.value)
    end

    invalid_tokens.each do |token|
      notify(
        :warning,
        message: 'quoted boolean value found',
        line: token.line,
        column: token.column,
        token: token,
        description: 'Check the manifest tokens for any double or single quoted strings containing only a boolean value and record a warning for each instance found.',
        help_uri: nil,
      )
    end
  end

  def fix(problem)
    problem[:token].type = problem[:token].value.upcase.to_sym
  end
end
PuppetLint.configuration.send('disable_quoted_booleans')
