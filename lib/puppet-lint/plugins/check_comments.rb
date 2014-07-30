# Public: Check the manifest tokens for any comments started with slashes
# (//) and record a warning for each instance found.
PuppetLint.new_check(:slash_comments) do
  def check
    tokens.select { |token|
      token.type == :SLASH_COMMENT
    }.each do |token|
      notify :warning, {
        :message => '// comment found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].type = :COMMENT
  end
end

# Public: Check the manifest tokens for any comments encapsulated with
# slash-asterisks (/* */) and record a warning for each instance found.
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
    comment_lines = problem[:token].value.split("\n")
    first_line = comment_lines.shift
    problem[:token].type = :COMMENT
    problem[:token].value = " #{first_line}"

    index = tokens.index(problem[:token].next_token)
    comment_lines.reverse.each do |line|
      [
        PuppetLint::Lexer::Token.new(:COMMENT, " #{line}", 0, 0),
        PuppetLint::Lexer::Token.new(:INDENT, problem[:token].prev_token.value.dup, 0, 0),
        PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0),
      ].each do |new_token|
        tokens.insert(index, new_token)
      end
    end
  end
end
