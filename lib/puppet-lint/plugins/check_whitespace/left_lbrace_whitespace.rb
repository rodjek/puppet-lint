# Public: Check the manifest tokens for whitespace before left bracket that is missing and record a warning for each instance found.
# #
# https://docs.puppet.com/puppet/latest/style_guide.html#spacing-indentation-and-whitespace 
PuppetLint.new_check(:left_lbrace_whitespace) do
  def check
    tokens.each do |token|
      unless token.next_token.nil?
        if (token.type != :WHITESPACE && token.next_token.type == :LBRACE)
          notify :warning, {
            :message => 'space needed on left side of opening bracket',
            :line    => token.line,
            :column  => token.column,
            :token   => token,
          }
        end
      end
    end
  end

  def fix(problem)
       index = tokens.index(problem[:token].next_token)
       tokens.insert(index, PuppetLint::Lexer::Token.new(:WHITESPACE, " ", 0, 0))
  end
end
