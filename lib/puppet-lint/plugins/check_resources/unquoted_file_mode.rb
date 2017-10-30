# Public: Check the tokens of each File resource instance for a mode
# parameter and if found, record a warning if the value of that parameter is
# not a quoted string.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#file-modes
PuppetLint.new_check(:unquoted_file_mode) do
  TOKEN_TYPES = Set[:NAME, :NUMBER]

  def check
    resource_indexes.each do |resource|
      next unless resource[:type].value == 'file' || resource[:type].value == 'concat'

      resource[:param_tokens].select { |param_token|
        param_token.value == 'mode' &&
          TOKEN_TYPES.include?(param_token.next_code_token.next_code_token.type)
      }.each do |param_token|
        value_token = param_token.next_code_token.next_code_token
        notify(
          :warning,
          :message => 'unquoted file mode',
          :line    => value_token.line,
          :column  => value_token.column,
          :token   => value_token
        )
      end
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end
