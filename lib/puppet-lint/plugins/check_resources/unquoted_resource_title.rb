# All resource titles should be quoted.
#
# @example What you have done
#   service { apache:
#     ensure => running,
#   }
#
# @example What you should have done
#   service { 'apache':
#     ensure => running,
#   }
#
# @style_guide #resource-names
# @enabled true
PuppetLint.new_check(:unquoted_resource_title) do
  # Check the manifest tokens for any resource titles / namevars that are not
  # quoted and record a warning for each instance found.
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
