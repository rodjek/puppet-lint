# Public: Check the manifest tokens for any arrows (=>) in a grouping ({}) that
# are not aligned with other arrows in that grouping.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:arrow_alignment) do
  COMMENT_TYPES = Set[:COMMENT, :SLASH_COMMENT, :MLCOMMENT]

  def check
    resource_indexes.each do |res_idx|
      arrow_column = [0]
      level_idx = 0
      level_tokens = []
      param_column = [nil]
      resource_tokens = res_idx[:tokens]
      resource_tokens.reject! do |token|
        COMMENT_TYPES.include?(token.type)
      end

      # If this is a single line resource, skip it
      first_arrow = resource_tokens.index { |r| r.type == :FARROW }
      last_arrow = resource_tokens.rindex { |r| r.type == :FARROW }
      next if first_arrow.nil?
      next if last_arrow.nil?
      next if resource_tokens[first_arrow].line == resource_tokens[last_arrow].line

      resource_tokens.each do |token|
        if token.type == :FARROW
          param_token = token.prev_code_token

          if param_token.type == :DQPOST
            param_length = 0
            iter_token = param_token
            while iter_token.type != :DQPRE
              param_length += iter_token.to_manifest.length
              iter_token = iter_token.prev_token
            end
            param_length += iter_token.to_manifest.length
          else
            param_length = param_token.to_manifest.length
          end

          if param_column[level_idx].nil?
            param_column[level_idx] = if param_token.type == :DQPOST
                                        iter_token.column
                                      else
                                        param_token.column
                                      end
          end

          if (level_tokens[level_idx] ||= []).any? { |t| t.line == token.line }
            this_arrow_column = param_column[level_idx] + param_length + 1
          else
            this_arrow_column = param_token.column + param_token.to_manifest.length
            this_arrow_column += 1 unless param_token.type == :DQPOST
          end

          if arrow_column[level_idx] < this_arrow_column
            arrow_column[level_idx] = this_arrow_column
          end

          (level_tokens[level_idx] ||= []) << token
        elsif token.type == :LBRACE
          level_idx += 1
          arrow_column << 0
          level_tokens[level_idx] ||= []
          param_column << nil
        elsif token.type == :RBRACE || token.type == :SEMIC
          if (level_tokens[level_idx] ||= []).map(&:line).uniq.length > 1
            level_tokens[level_idx].each do |arrow_tok|
              next if arrow_tok.column == arrow_column[level_idx] || level_tokens[level_idx].size == 1

              arrows_on_line = level_tokens[level_idx].select { |t| t.line == arrow_tok.line }
              notify(
                :warning,
                :message        => "indentation of => is not properly aligned (expected in column #{arrow_column[level_idx]}, but found it in column #{arrow_tok.column})",
                :line           => arrow_tok.line,
                :column         => arrow_tok.column,
                :token          => arrow_tok,
                :arrow_column   => arrow_column[level_idx],
                :newline        => arrows_on_line.index(arrow_tok) != 0,
                :newline_indent => param_column[level_idx] - 1
              )
            end
          end
          arrow_column[level_idx] = 0
          level_tokens[level_idx].clear
          param_column[level_idx] = nil
          level_idx -= 1
        end
      end
    end
  end

  def fix(problem)
    if problem[:newline]
      index = tokens.index(problem[:token].prev_code_token.prev_token)

      # insert newline
      tokens.insert(index, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))

      # indent the parameter to the correct depth
      problem[:token].prev_code_token.prev_token.type = :INDENT
      problem[:token].prev_code_token.prev_token.value = ' ' * problem[:newline_indent]

      end_param_idx = tokens.index(problem[:token].prev_code_token)
      start_param_idx = tokens.index(problem[:token].prev_token_of([:INDENT, :NEWLINE]))
      param_length = tokens[start_param_idx..end_param_idx].map { |r| r.to_manifest.length }.reduce(0) { |sum, x| sum + x } + 1
      new_ws_len = problem[:arrow_column] - param_length
    else
      new_ws_len = if problem[:token].prev_token.type == :WHITESPACE
                     problem[:token].prev_token.to_manifest.length
                   else
                     0
                   end
      new_ws_len += (problem[:arrow_column] - problem[:token].column)
    end

    raise PuppetLint::NoFix if new_ws_len < 0
    new_ws = ' ' * new_ws_len

    if problem[:token].prev_token.type == :WHITESPACE
      problem[:token].prev_token.value = new_ws
    else
      index = tokens.index(problem[:token].prev_token)
      tokens.insert(index + 1, PuppetLint::Lexer::Token.new(:WHITESPACE, new_ws, 0, 0))
    end
  end
end
