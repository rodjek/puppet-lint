# Public: Check the raw manifest string for lines containing hard tab
# characters and record an error for each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:hard_tabs) do
  WHITESPACE_TYPES = Set[:INDENT, :WHITESPACE]

  def check
    invalid_tokens = tokens.select do |token|
      WHITESPACE_TYPES.include?(token.type) && token.value.include?("\t")
    end

    invalid_tokens.each do |token|
      notify(
        :error,
        message: 'tab character found',
        line: token.line,
        column: token.column,
        token: token,
        description: 'Check the raw manifest string for lines containing hard tab characters and record an error for each instance found.',
        help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace',
      )
    end
  end

  def fix(problem)
    problem[:token].value.gsub!("\t", '  ')
  end
end
