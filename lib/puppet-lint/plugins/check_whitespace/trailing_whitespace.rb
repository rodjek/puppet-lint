# Public: Check the manifest tokens for lines ending with whitespace and record
# an error for each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:trailing_whitespace) do
  def check
    whitespace = tokens.select do |token|
      [:WHITESPACE, :INDENT].include?(token.type)
    end

    whitespace_at_eol = whitespace.select do |token|
      token.next_token.nil? || token.next_token.type == :NEWLINE
    end

    whitespace_at_eol.each do |token|
      notify(
        :error,
        message: 'trailing whitespace found',
        line: token.line,
        column: token.column,
        token: token,
        description: 'Check the manifest tokens for lines ending with whitespace and record an error for each instance found.',
        help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace',
      )
    end
  end

  def fix(problem)
    return if problem[:token].nil?

    prev_token = problem[:token].prev_token
    next_token = problem[:token].next_token
    prev_token.next_token = next_token
    next_token.prev_token = prev_token unless next_token.nil?
    tokens.delete(problem[:token])
  end
end
