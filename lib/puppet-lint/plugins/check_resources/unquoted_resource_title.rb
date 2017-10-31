# Public: Check the manifest tokens for any resource titles / namevars that
# are not quoted and record a warning for each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#resource-names
PuppetLint.new_check(:unquoted_resource_title) do
  def check
    title_tokens.each do |token|
      next unless token.type == :NAME

      notify(
        :warning,
        :message => 'unquoted resource title',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end
