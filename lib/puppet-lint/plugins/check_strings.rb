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
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :SSTRING
        contents = token.last[:value]
        line_no = token.last[:line]

        if contents.include? '${'
          notify :error, :message =>  "single quoted string containing a variable found", :linenumber => token.last[:line]
        end
      end
    end
  end

  check 'quoted_booleans' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if [:STRING, :SSTRING, :DQTEXT].include? token.first
        contents = token.last[:value]
        line_no = token.last[:line]

        if ['true', 'false'].include? contents
          notify :warning, :message =>  "quoted boolean value found", :linenumber => token.last[:line]
        end
      end
    end
  end
end
