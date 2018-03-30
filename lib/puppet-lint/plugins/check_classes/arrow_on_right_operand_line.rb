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
        :message => "arrow should be on the right operand's line",
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    return if problem[:token].nil?

    arrow_token = problem[:token]
    left_operand_token = arrow_token.prev_code_token
    right_operand_token = arrow_token.next_code_token

    # Move arrow token to just before the right operand
    remove_token(arrow_token)
    right_operand_index = tokens.index(right_operand_token)
    add_token(right_operand_index, arrow_token)
    whitespace_token = PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', right_operand_token.line, 3)
    add_token(right_operand_index + 1, whitespace_token)

    # Remove trailing whitespace after left operand (if it exists)
    return unless left_operand_token.next_token.type == :WHITESPACE
    trailing_whitespace_token = left_operand_token.next_token
    remove_token(trailing_whitespace_token) if [:NEWLINE, :WHITESPACE].include?(trailing_whitespace_token.next_token.type)
  end
end
