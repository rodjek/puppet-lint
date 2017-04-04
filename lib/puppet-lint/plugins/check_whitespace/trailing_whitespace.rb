# Public: Check the manifest tokens for lines ending with whitespace and record
# an error for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:trailing_whitespace) do
  def check
    tokens.select { |token|
      [:WHITESPACE, :INDENT].include?(token.type)
    }.select { |token|
      token.next_token.nil? || token.next_token.type == :NEWLINE
    }.each do |token|
      notify :error, {
        :message => 'trailing whitespace found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    prev_token = problem[:token].prev_token
    next_token = problem[:token].next_token
    prev_token.next_token = next_token
    next_token.prev_token = prev_token unless next_token.nil?
    tokens.delete(problem[:token])
  end
end
