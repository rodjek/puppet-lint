# In the interest of clarity, symbolic links should be declared by using an
# ensure value of `ensure => link` and explicitly specifying a value for the
# `target` attribute. Using a path to the target as the ensure value is not
# recommended.
#
# @example What you have done
#   file { '/tmp/foo':
#     ensure => '/tmp/bar',
#   }
#
# @example What you should have done
#   file { '/tmp/foo':
#     ensure => link,
#     target => '/tmp/bar',
#   }
#
# @style_guide #symbolic-links
# @enabled true
PuppetLint.new_check(:ensure_not_symlink_target) do
  # Check the tokens of each File resource instance for an ensure parameter
  # and record a warning if the value of that parameter looks like a symlink
  # target (starts with a '/').
  def check
    resource_indexes.each do |resource|
      next unless resource[:type].value == 'file'

      resource[:param_tokens].select { |param_token|
        param_token.value == 'ensure'
      }.each do |ensure_token|
        value_token = ensure_token.next_code_token.next_code_token
        next unless value_token.value.start_with?('/')

        notify(
          :warning,
          :message     => 'symlink target specified in ensure attr',
          :line        => value_token.line,
          :column      => value_token.column,
          :param_token => ensure_token,
          :value_token => value_token
        )
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
    ].reverse_each do |new_token|
      tokens.insert(index, new_token)
    end
  end
end
