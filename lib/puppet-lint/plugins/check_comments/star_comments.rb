# Public: Check the manifest tokens for any comments encapsulated with
# slash-asterisks (/* */) and record a warning for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#comments
PuppetLint.new_check(:star_comments) do
  def check
    tokens.select { |token|
      token.type == :MLCOMMENT
    }.each do |token|
      notify :warning, {
        :message => '/* */ comment found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
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
      tokens.insert(index, PuppetLint::Lexer::Token.new(:COMMENT, " #{line}", 0, 0))
      tokens.insert(index, PuppetLint::Lexer::Token.new(:INDENT, indent, 0, 0)) if indent
      tokens.insert(index, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))
    end
  end
end
