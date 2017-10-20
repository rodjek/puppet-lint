# Your manifests must not contain any trailing whitespace on any line.
#
# @style_guide #spacing-indentation-and-whitespace
# @enabled true
PuppetLint.new_check(:trailing_whitespace) do
  # Check the manifest tokens for lines ending with whitespace and record an
  # error for each instance found.
  def check
    tokens.select { |token|
      [:WHITESPACE, :INDENT].include?(token.type)
    }.select { |token|
      token.next_token.nil? || token.next_token.type == :NEWLINE
    }.each do |token|
      notify(
        :error,
        :message => 'trailing whitespace found',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
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
