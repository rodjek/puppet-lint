# All variables should be enclosed in braces (`{}`) when being interpolated in
# a string.
#
# @example What you have done
#   $foo = "bar $baz"
#
# @example What you should have done
#   $foo = "bar ${baz}"
#
# @style_guide #quoting
# @enabled true
PuppetLint.new_check(:variables_not_enclosed) do
  # Check the manifest tokens for any variables in a string that have not been
  # enclosed by braces ({}) and record a warning for each instance found.
  def check
    tokens.select { |r|
      r.type == :UNENC_VARIABLE
    }.each do |token|
      notify(
        :warning,
        :message => 'variable not enclosed in {}',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    problem[:token].type = :VARIABLE
  end
end
