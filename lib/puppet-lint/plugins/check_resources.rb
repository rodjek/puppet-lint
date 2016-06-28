# Public: Check the manifest tokens for any resource titles / namevars that
# are not quoted and record a warning for each instance found.
PuppetLint.new_check(:unquoted_resource_title) do
  def check
    title_tokens.each do |token|
      if token.type == :NAME
        notify :warning, {
          :message => 'unquoted resource title',
          :line    => token.line,
          :column  => token.column,
          :token   => token,
        }
      end
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end

# Public: Check the tokens of each resource instance for an ensure parameter
# and if found, check that it is the first parameter listed.  If it is not
# the first parameter, record a warning.
PuppetLint.new_check(:ensure_first_param) do
  def check
    resource_indexes.each do |resource|
      next if [:CLASS].include? resource[:type].type
      ensure_attr_index = resource[:param_tokens].index { |param_token|
        param_token.value == 'ensure'
      }

      unless ensure_attr_index.nil?
        if ensure_attr_index > 0
          ensure_token = resource[:param_tokens][ensure_attr_index]
          notify :warning, {
            :message => "ensure found on line but it's not the first attribute",
            :line    => ensure_token.line,
            :column  => ensure_token.column,
          }
        end
      end
    end
  end
end

# Public: Check the tokens of each resource instance for any duplicate
# parameters and record a warning for each instance found.
PuppetLint.new_check(:duplicate_params) do
  def check
    resource_indexes.each do |resource|
      seen_params = {}
      level = 0

      resource[:tokens].each_with_index do |token, idx|
        case token.type
        when :LBRACE
          level += 1
          next
        when :RBRACE
          seen_params.delete(level)
          level -= 1
          next
        when :FARROW
          prev_token = token.prev_code_token
          next unless prev_token.type == :NAME

          if (seen_params[level] ||= Set.new).include?(prev_token.value)
            notify :error, {
              :message => 'duplicate parameter found in resource',
              :line    => prev_token.line,
              :column  => prev_token.column,
            }
          else
            seen_params[level] << prev_token.value
          end
        end
      end
    end
  end
end

# Public: Check the tokens of each File resource instance for a mode
# parameter and if found, record a warning if the value of that parameter is
# not a quoted string.
PuppetLint.new_check(:unquoted_file_mode) do
  TOKEN_TYPES = Set[:NAME, :NUMBER]

  def check
    resource_indexes.each do |resource|
      if resource[:type].value == "file" or resource[:type].value == "concat"
        resource[:param_tokens].select { |param_token|
          param_token.value == 'mode' &&
            TOKEN_TYPES.include?(param_token.next_code_token.next_code_token.type)
        }.each do |param_token|
          value_token = param_token.next_code_token.next_code_token
          notify :warning, {
            :message => 'unquoted file mode',
            :line    => value_token.line,
            :column  => value_token.column,
            :token   => value_token,
          }
        end
      end
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end

# Public: Check the tokens of each File resource instance for a mode
# parameter and if found, record a warning if the value of that parameter is
# not a 4 digit octal value (0755) or a symbolic mode ('o=rwx,g+r').
PuppetLint.new_check(:file_mode) do
  MSG = 'mode should be represented as a 4 digit octal value or symbolic mode'
  SYM_RE = "([ugoa]*[-=+][-=+rstwxXugo]*)(,[ugoa]*[-=+][-=+rstwxXugo]*)*"
  IGNORE_TYPES = Set[:VARIABLE, :UNDEF]
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

# Public: Check the tokens of each File resource instance for an ensure
# parameter and record a warning if the value of that parameter looks like
# a symlink target (starts with a '/').
PuppetLint.new_check(:ensure_not_symlink_target) do
  def check
    resource_indexes.each do |resource|
      if resource[:type].value == "file"
        resource[:param_tokens].select { |param_token|
          param_token.value == 'ensure'
        }.each do |ensure_token|
          value_token = ensure_token.next_code_token.next_code_token
          if value_token.value.start_with? '/'
            notify :warning, {
              :message     => 'symlink target specified in ensure attr',
              :line        => value_token.line,
              :column      => value_token.column,
              :param_token => ensure_token,
              :value_token => value_token,
            }
          end
        end
      end
    end
  end

  def fix(problem)
    index = tokens.index(problem[:value_token])

    [
      PuppetLint::Lexer::Token.new(:NAME, 'symlink', 0, 0),
      PuppetLint::Lexer::Token.new(:COMMA, ',', 0, 0),
      PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0),
      PuppetLint::Lexer::Token.new(:INDENT, problem[:param_token].prev_token.value.dup, 0, 0),
      PuppetLint::Lexer::Token.new(:NAME, 'target', 0, 0),
      PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', 0, 0),
      PuppetLint::Lexer::Token.new(:FARROW, '=>', 0, 0),
      PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', 0, 0),
    ].reverse.each do |new_token|
      tokens.insert(index, new_token)
    end
  end
end
