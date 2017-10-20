# All strings that do not contain variables or escape characters like `\n` or
# `\t` should be enclosed in single quotes.
#
# @example What you have done
#   $foo = "bar"
#
# @example What you should have done
#   $foo = 'bar'
#
# @style_guide #quoting
# @enabled true
PuppetLint.new_check(:double_quoted_strings) do
  ESCAPE_CHAR_RE = %r{(\\\$|\\"|\\'|'|\r|\t|\\t|\n|\\n|\\\\)}

  # Check the manifest tokens for any double quoted strings that don't contain
  # any variables or common escape characters and record a warning for each
  # instance found.
  def check
    tokens.select { |token|
      token.type == :STRING &&
        token.value.gsub(' ' * token.column, "\n")[ESCAPE_CHAR_RE].nil?
    }.each do |token|
      notify(
        :warning,
        :message => 'double quoted string containing no variables',
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
