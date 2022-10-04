# Public: Check the manifest tokens for any comments started with slashes
# (//) and record a warning for each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#comments
PuppetLint.new_check(:slash_comments) do
  def check
    invalid_tokens = tokens.select { |token| token.type == :SLASH_COMMENT }

    invalid_tokens.each do |token|
      notify(
        :warning,
        message: '// comment found',
        line: token.line,
        column: token.column,
        token: token,
        description: 'Check the manifest tokens for any comments started with slashes (//) and record a warning for each instance found.',
        help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#comments',
      )
    end
  end

  def fix(problem)
    problem[:token].type = :COMMENT
  end
end
