# Although the Puppet language allows you to use `//` style comments, it is
# recommended that you use `#` style comments.
#
# @example What you have done
#   // my awesome comment
#
# @example What you should have done
#   # my awesome comment
#
# @style_guide #comments
# @enabled true
PuppetLint.new_check(:slash_comments) do
  # Check the manifest tokens for any comments started with slashes (//) and
  # record a warning for each instance found.
  def check
    tokens.select { |token|
      token.type == :SLASH_COMMENT
    }.each do |token|
      notify(
        :warning,
        :message => '// comment found',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    problem[:token].type = :COMMENT
  end
end
