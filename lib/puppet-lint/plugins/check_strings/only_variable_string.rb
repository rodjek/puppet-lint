# Public: Check the manifest tokens for double quoted strings that contain
# a single variable only and record a warning for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#quoting
PuppetLint.new_check(:only_variable_string) do
  VAR_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  def check
    tokens.each_with_index do |start_token, start_token_idx|
      if start_token.type == :DQPRE and start_token.value == ''
        var_token = start_token.next_token
        if VAR_TYPES.include? var_token.type
          eos_offset = 2
          loop do
            eos_token = tokens[start_token_idx + eos_offset]
            case eos_token.type
            when :LBRACK
              eos_offset += 3
            when :DQPOST
              if eos_token.value == ''
                if eos_token.next_code_token && eos_token.next_code_token.type == :FARROW
                  break
                end
                notify :warning, {
                  :message     => 'string containing only a variable',
                  :line        => var_token.line,
                  :column      => var_token.column,
                  :start_token => start_token,
                  :var_token   => var_token,
                  :end_token   => eos_token,
                }
              end
              break
            else
              break
            end
          end
        end
      end
    end
  end

  def fix(problem)
    prev_token = problem[:start_token].prev_token
    prev_code_token = problem[:start_token].prev_code_token
    next_token = problem[:end_token].next_token
    next_code_token = problem[:end_token].next_code_token
    var_token = problem[:var_token]

    tokens.delete(problem[:start_token])
    tokens.delete(problem[:end_token])

    prev_token.next_token = var_token unless prev_token.nil?
    prev_code_token.next_code_token = var_token unless prev_code_token.nil?
    next_code_token.prev_code_token = var_token unless next_code_token.nil?
    next_token.prev_token = var_token unless next_token.nil?
    var_token.type = :VARIABLE
    var_token.next_token = next_token
    var_token.next_code_token = next_code_token
    var_token.prev_code_token = prev_code_token
    var_token.prev_token = prev_token
  end
end
