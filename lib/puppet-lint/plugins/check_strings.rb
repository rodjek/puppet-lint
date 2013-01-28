class PuppetLint::Plugins::CheckStrings < PuppetLint::CheckPlugin
  # Public: Check the manifest tokens for any double quoted strings that don't
  # contain any variables or common escape characters and record a warning for
  # each instance found.
  #
  # Returns nothing.
  check 'double_quoted_strings' do
    tokens.select { |r|
      r.type == :STRING
    }.each { |r|
      r.value.gsub!(' '*r.column, "\n")
    }.select { |r|
      r.value[/(\t|\\t|\n|\\n)/].nil?
    }.each do |token|
      if PuppetLint.configuration.fix
        token.type = :SSTRING
        notify_type = :fixed
      else
        notify_type = :warning
      end

      notify notify_type, {
        :message    => 'double quoted string containing no variables',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end

  # Public: Check the manifest tokens for double quoted strings that contain
  # a single variable only and record a warning for each instance found.
  #
  # Returns nothing.
  check 'only_variable_string' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.type == :DQPRE and token.value == ''
        if {:VARIABLE => true, :UNENC_VARIABLE => true}.include? tokens[token_idx + 1].type
          if tokens[token_idx + 2].type == :DQPOST
            if tokens[token_idx + 2].value == ''
              if PuppetLint.configuration.fix
                prev_token = token.prev_token
                prev_code_token = token.prev_code_token
                next_token = token.next_token.next_token.next_token
                next_code_token = token.next_token.next_token.next_code_token
                var_token = token.next_token

                tokens.delete_at(token_idx + 2)
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
                notify_token = var_token
              else
                notify_type = :warning
                notify_token = tokens[token_idx + 1]
              end

              notify notify_type, {
                :message    => 'string containing only a variable',
                :linenumber => notify_token.line,
                :column     => notify_token.column,
              }
            end
          end
        end
      end
    end
  end

  # Public: Check the manifest tokens for any variables in a string that have
  # not been enclosed by braces ({}) and record a warning for each instance
  # found.
  #
  # Returns nothing.
  check 'variables_not_enclosed' do
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

  # Public: Check the manifest tokens for any single quoted strings containing
  # a enclosed variable and record an error for each instance found.
  #
  # Returns nothing.
  check 'single_quote_string_with_variables' do
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

  # Public: Check the manifest tokens for any double or single quoted strings
  # containing only a boolean value and record a warning for each instance
  # found.
  #
  # Returns nothing.
  check 'quoted_booleans' do
    tokens.select { |r|
      {:STRING => true, :SSTRING => true}.include?(r.type) && %w{true false}.include?(r.value)
    }.each do |token|
      notify :warning, {
        :message    => 'quoted boolean value found',
        :linenumber => token.line,
        :column     => token.column,
      }

      if PuppetLint.configuration.fix
        token.type = token.value.upcase.to_sym
      end
    end
  end
end
