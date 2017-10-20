# Boolean values (`true` and `false`) behave differently when quoted (`'true'`
# and `'false'`), which can lead to a fair bit of confusion. As a general rule,
# you sholud never quote booleans. This is not a style issue, rather a common
# mistake.
#
# @example What you have done
#   file { '/tmp/foo':
#     purge => 'true',
#   }
#
# @example What you should have done
#   file { '/tmp/foo':
#     purge => true,
#   }
#
# @enabled true
PuppetLint.new_check(:quoted_booleans) do
  STRING_TYPES = Set[:STRING, :SSTRING]
  BOOLEANS = Set['true', 'false']

  # Check the manifest tokens for any double or single quoted strings
  # containing only a boolean value and record a warning for each instance
  # found.
  def check
    tokens.select { |r|
      STRING_TYPES.include?(r.type) && BOOLEANS.include?(r.value)
    }.each do |token|
      notify(
        :warning,
        :message => 'quoted boolean value found',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    problem[:token].type = problem[:token].value.upcase.to_sym
  end
end
