# Public: Check the manifest tokens for any double quoted strings that don't
# contain any variables or common escape characters and record a warning for
# each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#quoting
PuppetLint.new_check(:double_quoted_strings) do
  def check
    tokens.select { |token|
      token.type == :STRING
    }.map { |token|
      [token, token.value.gsub(' '*token.column, "\n")]
    }.select { |token, sane_value|
      sane_value[/(\\\$|\\"|\\'|'|\r|\t|\\t|\n|\\n|\\\\)/].nil?
    }.each do |token, sane_value|
      notify :warning, {
        :message => 'double quoted string containing no variables',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end

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
    lexer.delete_token(problem[:start_token])
    lexer.delete_token(problem[:end_token])

    var_token = problem[:var_token]
    var_token.type = :VARIABLE
  end
end
PuppetLint.configuration.send('only_variable_string')

# Public: Check the manifest tokens for any variables in a string that have
# not been enclosed by braces ({}) and record a warning for each instance
# found.
#
# https://docs.puppet.com/guides/style_guide.html#quoting
PuppetLint.new_check(:variables_not_enclosed) do
  def check
    tokens.select { |r|
      r.type == :UNENC_VARIABLE
    }.each do |token|
      notify :warning, {
        :message => 'variable not enclosed in {}',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = :VARIABLE
  end
end

# Public: Check the manifest tokens for any single quoted strings containing
# a enclosed variable and record an error for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#quoting
PuppetLint.new_check(:single_quote_string_with_variables) do
  def check
    tokens.select { |r|
      r.type == :SSTRING && r.value.include?('${') && (! r.prev_token.prev_token.value.match(%r{inline_(epp|template)}) )
    }.each do |token|
      notify :error, {
        :message => 'single quoted string containing a variable found',
        :line    => token.line,
        :column  => token.column,
      }
    end
  end
end

# Public: Check the manifest tokens for any double or single quoted strings
# containing only a boolean value and record a warning for each instance
# found.
#
# No style guide reference
PuppetLint.new_check(:quoted_booleans) do
  STRING_TYPES = Set[:STRING, :SSTRING]
  BOOLEANS = Set['true', 'false']

  def check
    tokens.select { |r|
      STRING_TYPES.include?(r.type) && BOOLEANS.include?(r.value)
    }.each do |token|
      notify :warning, {
        :message => 'quoted boolean value found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = problem[:token].value.upcase.to_sym
  end
end
PuppetLint.configuration.send('disable_quoted_booleans')

# Public: Check the manifest tokens for any puppet:// URL strings where the
# path section doesn't start with modules/ and record a warning for each
# instance found.
#
# No style guide reference
PuppetLint.new_check(:puppet_url_without_modules) do
  def check
    tokens.select { |token|
      (token.type == :SSTRING || token.type == :STRING || token.type == :DQPRE) && token.value.start_with?('puppet://')
    }.reject { |token|
      token.value[/puppet:\/\/.*?\/(.+)/, 1].start_with?('modules/') unless token.value[/puppet:\/\/.*?\/(.+)/, 1].nil?
    }.each do |token|
      notify :warning, {
        :message => 'puppet:// URL without modules/ found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].value.gsub!(/(puppet:\/\/.*?\/)/, '\1modules/')
  end
end
PuppetLint.configuration.send('puppet_url_without_modules')
