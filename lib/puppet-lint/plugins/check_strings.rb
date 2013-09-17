# Public: Check the manifest tokens for any double quoted strings that don't
# contain any variables or common escape characters and record a warning for
# each instance found.
PuppetLint.new_check(:double_quoted_strings) do
  def check
    tokens.select { |r|
      r.type == :STRING
    }.each { |r|
      r.value.gsub!(' '*r.column, "\n")
    }.select { |r|
      r.value[/(\t|\\t|\n|\\n)/].nil?
    }.each do |token|
      notify :warning, {
        :message    => 'double quoted string containing no variables',
        :linenumber => token.line,
        :column     => token.column,
        :token      => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end

# Public: Check the manifest tokens for double quoted strings that contain
# a single variable only and record a warning for each instance found.
PuppetLint.new_check(:only_variable_string) do
  def check
    variable_tokens = Set.new [:VARIABLE, :UNENC_VARIABLE]

    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.type == :DQPRE and token.value == ''
        var_token = token.next_token
        if variable_tokens.include? var_token.type
          eos_offset = 2
          loop do
            eos_token = tokens[token_idx + eos_offset]
            case eos_token.type
            when :LBRACK
              eos_offset += 3
            when :DQPOST
              if eos_token.value == ''
                if PuppetLint.configuration.fix
                  prev_token = token.prev_token
                  prev_code_token = token.prev_code_token
                  next_token = eos_token.next_token
                  next_code_token = eos_token.next_code_token

                  tokens.delete_at(token_idx + eos_offset)
                  tokens.delete_at(token_idx)

                  prev_token.next_token = var_token unless prev_token.nil?
                  prev_code_token.next_code_token = var_token unless prev_code_token.nil?
                  next_code_token.prev_code_token = var_token unless next_code_token.nil?
                  next_token.prev_token = var_token unless next_token.nil?
                  var_token.type = :VARIABLE
                  var_token.next_token = next_token
                  var_token.next_code_token = next_code_token
                  var_token.prev_code_token = prev_code_token
                  var_token.prev_token = prev_token
                  notify_type = :fixed
                else
                  notify_type = :warning
                end

                notify notify_type, {
                  :message    => 'string containing only a variable',
                  :linenumber => var_token.line,
                  :column     => var_token.column,
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
end

# Public: Check the manifest tokens for any variables in a string that have
# not been enclosed by braces ({}) and record a warning for each instance
# found.
PuppetLint.new_check(:variables_not_enclosed) do
  def check
    tokens.select { |r|
      r.type == :UNENC_VARIABLE
    }.each do |token|
      if PuppetLint.configuration.fix
        token.type = :VARIABLE
        notify_type = :fixed
      else
        notify_type = :warning
      end

      notify notify_type, {
        :message    => 'variable not enclosed in {}',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end

# Public: Check the manifest tokens for any single quoted strings containing
# a enclosed variable and record an error for each instance found.
PuppetLint.new_check(:single_quote_string_with_variables) do
  def check
    tokens.select { |r|
      r.type == :SSTRING && r.value.include?('${')
    }.each do |token|
      notify :error, {
        :message    => 'single quoted string containing a variable found',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end

# Public: Check the manifest tokens for any double or single quoted strings
# containing only a boolean value and record a warning for each instance
# found.
PuppetLint.new_check(:quoted_booleans) do
  def check
    tokens.select { |r|
      {:STRING => true, :SSTRING => true}.include?(r.type) && %w{true false}.include?(r.value)
    }.each do |token|
      if PuppetLint.configuration.fix
        token.type = token.value.upcase.to_sym
        notify_type = :fixed
      else
        notify_type = :warning
      end

      notify notify_type, {
        :message    => 'quoted boolean value found',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end

# Public: Check the manifest tokens for any puppet:// URL strings where the
# path section doesn't start with modules/ and record a warning for each
# instance found.
PuppetLint.new_check(:puppet_url_without_modules) do
  def check
    tokens.select { |token|
      token.type == :SSTRING && token.value.start_with?('puppet://')
    }.reject { |token|
      token.value[/puppet:\/\/.*?\/(.+)/, 1].start_with?('modules/')
    }.each do |token|
      notify :warning, {
        :message    => 'puppet:// URL without modules/ found',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end
