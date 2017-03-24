# Public: Check the manifest tokens for any double or single quoted strings
# containing only a boolean value and record a warning for each instance
# found.
#
# No style guide reference
PuppetLint.new_check(:quoted_booleans) do
  STRING_TYPES = Set[:STRING, :SSTRING]
  BOOLEANS = Set['true', 'false']

  def check
    tokens.select { |r|
      STRING_TYPES.include?(r.type) && BOOLEANS.include?(r.value)
    }.each do |token|
      notify :warning, {
        :message => 'quoted boolean value found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = problem[:token].value.upcase.to_sym
  end
end
