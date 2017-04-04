# Public: Check the tokens of each File resource instance for a mode
# parameter and if found, record a warning if the value of that parameter is
# not a 4 digit octal value (0755) or a symbolic mode ('o=rwx,g+r').
#
# https://docs.puppet.com/guides/style_guide.html#file-modes
PuppetLint.new_check(:file_mode) do
  MSG = 'mode should be represented as a 4 digit octal value or symbolic mode'
  SYM_RE = "([ugoa]*[-=+][-=+rstwxXugo]*)(,[ugoa]*[-=+][-=+rstwxXugo]*)*"
  IGNORE_TYPES = Set[:VARIABLE, :UNDEF, :FUNCTION_NAME]
  MODE_RE = Regexp.new(/\A([0-7]{4}|#{SYM_RE})\Z/)

  def check
    resource_indexes.each do |resource|
      if resource[:type].value == "file" or resource[:type].value == "concat"
        resource[:param_tokens].select { |param_token|
          param_token.value == 'mode'
        }.each do |param_token|
          value_token = param_token.next_code_token.next_code_token

          break if IGNORE_TYPES.include?(value_token.type)
          break if value_token.value =~ MODE_RE

          notify :warning, {
            :message => MSG,
            :line    => value_token.line,
            :column  => value_token.column,
            :token   => value_token,
          }
        end
      end
    end
  end

  def fix(problem)
    if problem[:token].value =~ /\A[0-7]{3}\Z/
      problem[:token].type = :SSTRING
      problem[:token].value = "0#{problem[:token].value.to_s}"
    else
      raise PuppetLint::NoFix
    end
  end
end
