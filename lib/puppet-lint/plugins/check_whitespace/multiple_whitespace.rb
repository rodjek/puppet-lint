# Public: Check the manifest tokens for multiple spaces in whitespace that is not after a newline and record a warning for each instance found.
# #
# https://docs.puppet.com/puppet/latest/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:multiple_whitespace) do
  def check
    whitespace_tokens = tokens.select { |r| r.type == :WHITESPACE}
    whitespace_tokens.each do |token|
      next if token.next_token.nil?
      if (token.value != " " && token.prev_token != :NEWLINE)
        unless [:FARROW, :EQUALS].include?(token.next_token.type)
          notify :warning, {
            :message => 'too many spaces',
            :line    => token.line,
            :column  => token.column,
            :token   => token,
          }
        end
      end
    end
  end

  def fix(problem)
    if problem[:token]
      problem[:token].value = " "
    end
  end
end
