class PuppetLint::Plugins::CheckStrings < PuppetLint::CheckPlugin
  check 'double_quoted_strings' do
    tokens.select { |r|
      r.type == :STRING
    }.reject { |r|
      r.value.include?('\t') || r.value.include?('\n')
    }.each do |token|
      notify :warning, {
        :message    => 'double quoted string containing no variables',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end

  check 'only_variable_string' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.type == :DQPRE and token.value == ''
        if [:VARIABLE, :UNENC_VARIABLE].include? tokens[token_idx + 1].type
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

  check 'quoted_booleans' do
    tokens.select { |r|
      [:STRING, :SSTRING].include?(r.type) && %w{true false}.include?(r.value)
    }.each do |token|
      notify :warning, {
        :message    => 'quoted boolean value found',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end
