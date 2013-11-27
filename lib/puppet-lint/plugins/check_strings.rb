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
      r.value[/(\\\$|\\"|\\'|\r|\t|\\t|\n|\\n)/].nil?
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
    variable_token_types = Set.new [:VARIABLE, :UNENC_VARIABLE]

    tokens.each_with_index do |start_token, start_token_idx|
      if start_token.type == :DQPRE and start_token.value == ''
        var_token = start_token.next_token
        if variable_token_types.include? var_token.type
          eos_offset = 2
          loop do
            eos_token = tokens[start_token_idx + eos_offset]
            case eos_token.type
            when :LBRACK
              eos_offset += 3
            when :DQPOST
              if eos_token.value == ''
                notify :warning, {
                  :message     => 'string containing only a variable',
                  :linenumber  => var_token.line,
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

# Public: Check the manifest tokens for any variables in a string that have
# not been enclosed by braces ({}) and record a warning for each instance
# found.
PuppetLint.new_check(:variables_not_enclosed) do
  def check
    tokens.select { |r|
      r.type == :UNENC_VARIABLE
    }.each do |token|
      notify :warning, {
        :message    => 'variable not enclosed in {}',
        :linenumber => token.line,
        :column     => token.column,
        :token      => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = :VARIABLE
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
      string_token_types.include?(r.type) && %w{true false}.include?(r.value)
    }.each do |token|
      notify :warning, {
        :message    => 'quoted boolean value found',
        :linenumber => token.line,
        :column     => token.column,
        :token      => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = problem[:token].value.upcase.to_sym
  end

  private
  def string_token_types
    Set[:STRING, :SSTRING]
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
