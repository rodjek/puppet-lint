# Public: Check the tokens of each File resource instance for a mode
# parameter and if found, record a warning if the value of that parameter is
# not a 4 digit octal value (0755) or a symbolic mode ('o=rwx,g+r').
#
# https://puppet.com/docs/puppet/latest/style_guide.html#file-modes
PuppetLint.new_check(:file_mode) do
  MSG = 'mode should be represented as a 4 digit octal value or symbolic mode'.freeze
  SYM_RE = '([ugoa]*[-=+][-=+rstwxXugo]*)(,[ugoa]*[-=+][-=+rstwxXugo]*)*'.freeze
  IGNORE_TYPES = Set[:VARIABLE, :UNDEF, :FUNCTION_NAME]
  MODE_RE = %r{\A([0-7]{4}|#{SYM_RE})\Z}

  def check
    resource_indexes.each do |resource|
      next unless resource[:type].value == 'file' || resource[:type].value == 'concat'

      resource[:param_tokens].select { |param_token|
        param_token.value == 'mode'
      }.each do |param_token|
        value_token = param_token.next_code_token.next_code_token

        break if IGNORE_TYPES.include?(value_token.type)
        break if value_token.value =~ MODE_RE

        notify(
          :warning,
          :message => MSG,
          :line    => value_token.line,
          :column  => value_token.column,
          :token   => value_token
        )
      end
    end
  end

  def fix(problem)
    raise PuppetLint::NoFix unless problem[:token].value =~ %r{\A[0-7]{3}\Z}

    problem[:token].type = :SSTRING
    problem[:token].value = "0#{problem[:token].value}"
  end
end
