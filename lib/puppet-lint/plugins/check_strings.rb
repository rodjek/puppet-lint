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
      notify :warning, {
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
              notify :warning, {
                :message    => 'string containing only a variable',
                :linenumber => tokens[token_idx + 1].line,
                :column     => tokens[token_idx + 1].column,
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
      notify :warning, {
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
    end
  end
end
