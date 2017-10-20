# Although the Puppet language allows you to use `/* */` style multiline
# comments, it is recommended that you use multiple `#` style comments instead.
#
# @example What you have done
#   /* my awesome comment that describes
#    * exactly what I'm trying to do */
#
# @example What you should have done
#   # my awesome comment that describes
#   # exactly what I'm trying to do
#
# @style_guide #comments
# @enabled true
PuppetLint.new_check(:star_comments) do
  # Check the manifest tokens for any comments encapsulated with
  # slash-asterisks (/* */) and record a warning for each instance found.
  def check
    tokens.select { |token|
      token.type == :MLCOMMENT
    }.each do |token|
      notify(
        :warning,
        :message => '/* */ comment found',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    comment_lines = problem[:token].value.strip.split("\n").map(&:strip)

    first_line = comment_lines.shift
    problem[:token].type = :COMMENT
    problem[:token].value = " #{first_line}"

    index = tokens.index(problem[:token].next_token) || 1
    comment_lines.reverse.each do |line|
      indent = problem[:token].prev_token.nil? ? nil : problem[:token].prev_token.value.dup
      add_token(index, PuppetLint::Lexer::Token.new(:COMMENT, " #{line}", 0, 0))
      add_token(index, PuppetLint::Lexer::Token.new(:INDENT, indent, 0, 0)) if indent
      add_token(index, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))
    end
  end
end
