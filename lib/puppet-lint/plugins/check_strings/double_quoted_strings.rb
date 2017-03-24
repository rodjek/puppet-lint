# Public: Check the manifest tokens for any double quoted strings that don't
# contain any variables or common escape characters and record a warning for
# each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#quoting
PuppetLint.new_check(:double_quoted_strings) do
  def check
    tokens.select { |token|
      token.type == :STRING
    }.map { |token|
      [token, token.value.gsub(' '*token.column, "\n")]
    }.select { |token, sane_value|
      sane_value[/(\\\$|\\"|\\'|'|\r|\t|\\t|\n|\\n|\\\\)/].nil?
    }.each do |token, sane_value|
      notify :warning, {
        :message => 'double quoted string containing no variables',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end
