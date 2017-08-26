# Public: Test the manifest tokens for chaining arrow that is
# on the line of the left operand when the right operand is on another line.
#
# https://docs.puppet.com/guides/style_guide.html#chaining-arrow-syntax
PuppetLint.new_check(:arrow_on_right_operand_line) do
  def check
    tokens.select { |r| Set[:IN_EDGE, :IN_EDGE_SUB].include?(r.type) }.each do |token|
      if token.next_code_token.line != token.line
        notify(:warning,
          :message =>  'arrow should be on the right operand\'s line',
          :line    => token.line,
          :column  => token.column,
          :token   => token,
        )
      end
    end
  end

  def fix(problem)
    token = problem[:token]
    remove_token(token)

    # remove any excessive whitespace on the line
    temp_token = token.prev_code_token
    while (temp_token = temp_token.next_token)
      remove_token(temp_token) if whitespace?(temp_token)
      break if temp_token.type == :NEWLINE
    end

    index = tokens.index(token.next_code_token)
    add_token(index, token)

    whitespace_token = PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', temp_token.line + 1, 3)
    add_token(index + 1, whitespace_token)
  end

  def whitespace?(token)
    Set[:INDENT, :WHITESPACE].include?(token.type)
  end
end
