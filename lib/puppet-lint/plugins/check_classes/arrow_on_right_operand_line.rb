# Public: Test the manifest tokens for chaining arrow that is
# on the line of the left operand when the right operand is on another line.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#chaining-arrow-syntax
PuppetLint.new_check(:arrow_on_right_operand_line) do
  def check
    tokens.select { |r| Set[:IN_EDGE, :IN_EDGE_SUB].include?(r.type) }.each do |token|
      next if token.next_code_token.line == token.line

      notify(
        :warning,
        :message =>  'arrow should be on the right operand\'s line',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    token = problem[:token]

    prev_code_token = token.prev_code_token
    next_code_token = token.next_code_token
    indent_token = prev_code_token.prev_token_of(:INDENT)

    # Delete all tokens between the two code tokens the anchor is between
    temp_token = prev_code_token
    while (temp_token = temp_token.next_token) && (temp_token != next_code_token)
      remove_token(temp_token) unless temp_token == token
    end

    # Insert a newline and an indent before the arrow
    index = tokens.index(token)
    newline_token = PuppetLint::Lexer::Token.new(:NEWLINE, "\n", token.line, 0)
    add_token(index, newline_token)
    add_token(index + 1, indent_token) if indent_token

    # Insert a space between the arrow and the following code token
    index = tokens.index(token)
    whitespace_token = PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', token.line, 3)
    add_token(index + 1, whitespace_token)
  end
end
