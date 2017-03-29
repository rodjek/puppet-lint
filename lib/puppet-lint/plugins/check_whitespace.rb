# Public: Check the raw manifest string for lines containing hard tab
# characters and record an error for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:hard_tabs) do
  WHITESPACE_TYPES = Set[:INDENT, :WHITESPACE]

  def check
    tokens.select { |r|
      WHITESPACE_TYPES.include?(r.type) && r.value.include?("\t")
    }.each do |token|
      notify :error, {
        :message => 'tab character found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].value.gsub!("\t", '  ')
  end
end

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

# Public: Test the raw manifest string for lines containing more than 140
# characters and record a warning for each instance found.  The only exceptions
# to this rule are lines containing URLs and template() calls which would hurt
# readability if split.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:'140chars') do
  def check
    manifest_lines.each_with_index do |line, idx|
      unless line =~ /:\/\// || line =~ /template\(/
        if line.scan(/./mu).size > 140
          notify :warning, {
            :message => 'line has more than 140 characters',
            :line    => idx + 1,
            :column  => 140,
          }
        end
      end
    end
  end
end

# Public: Test the raw manifest string for lines containing more than 80
# characters. This is DISABLED by default and behaves like the default
# 140chars check by excepting URLs and template() calls.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace (older version)
PuppetLint.new_check(:'80chars') do
  def check
    manifest_lines.each_with_index do |line, idx|
      unless line =~ /:\/\// || line =~ /template\(/
        if line.scan(/./mu).size > 80
          notify :warning, {
            :message => 'line has more than 80 characters',
            :line    => idx + 1,
            :column  => 80,
          }
        end
      end
    end
  end
end
PuppetLint.configuration.send("disable_80chars")

# Public: Check the manifest tokens for any indentation not using 2 space soft
# tabs and record an error for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:'2sp_soft_tabs') do
  def check
    tokens.select { |r|
      r.type == :INDENT
    }.reject { |r|
      r.value.length % 2 == 0
    }.each do |token|
      notify :error, {
        :message => 'two-space soft tabs not used',
        :line    => token.line,
        :column  => token.column,
      }
    end
  end
end

# Public: Check the manifest tokens for any arrows (=>) in a grouping ({}) that
# are not aligned with other arrows in that grouping.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
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
        COMMENT_TYPES.include? token.type
      end

      # If this is a single line resource, skip it
      first_arrow = resource_tokens.index { |r| r.type == :FARROW }
      last_arrow = resource_tokens.rindex { |r| r.type == :FARROW }
      next if first_arrow.nil?
      next if last_arrow.nil?
      next if resource_tokens[first_arrow].line == resource_tokens[last_arrow].line

      resource_tokens.each_with_index do |token, idx|
        if token.type == :FARROW
          (level_tokens[level_idx] ||= []) << token
          param_token = token.prev_code_token

          if param_token.type == :DQPOST
            param_length = 0
            iter_token = param_token
            while iter_token.type != :DQPRE do
              param_length += iter_token.to_manifest.length
              iter_token = iter_token.prev_token
            end
            param_length += iter_token.to_manifest.length
          else
            param_length = param_token.to_manifest.length
          end

          if param_column[level_idx].nil?
            if param_token.type == :DQPOST
              param_column[level_idx] = iter_token.column
            else
              param_column[level_idx] = param_token.column
            end
          end

          this_arrow_column = param_column[level_idx] + param_length + 1

          if arrow_column[level_idx] < this_arrow_column
            arrow_column[level_idx] = this_arrow_column
          end

        elsif token.type == :LBRACE
          level_idx += 1
          arrow_column << 0
          level_tokens[level_idx] ||= []
          param_column << nil
        elsif token.type == :RBRACE || token.type == :SEMIC
          if (level_tokens[level_idx] ||= []).map(&:line).uniq.length > 1
            level_tokens[level_idx].each do |arrow_tok|
              unless arrow_tok.column == arrow_column[level_idx] || level_tokens[level_idx].size == 1
                arrows_on_line = level_tokens[level_idx].select { |t| t.line == arrow_tok.line }
                notify :warning, {
                  :message        => "indentation of => is not properly aligned (expected in column #{arrow_column[level_idx]}, but found it in column #{arrow_tok.column})",
                  :line           => arrow_tok.line,
                  :column         => arrow_tok.column,
                  :token          => arrow_tok,
                  :arrow_column   => arrow_column[level_idx],
                  :newline        => !(arrows_on_line.index(arrow_tok) == 0),
                  :newline_indent => param_column[level_idx] - 1,
                }
              end
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

      #insert newline
      tokens.insert(index, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))

      # indent the parameter to the correct depth
      problem[:token].prev_code_token.prev_token.type = :INDENT
      problem[:token].prev_code_token.prev_token.value = ' ' * problem[:newline_indent]
    end

    end_param_idx = tokens.index(problem[:token].prev_code_token)
    start_param_idx = tokens.index(problem[:token].prev_token_of([:INDENT, :NEWLINE])) + 1
    param_length = tokens[start_param_idx..end_param_idx].map { |r| r.to_manifest.length }.inject(0) { |sum,x| sum + x }
    new_ws_len = (problem[:arrow_column] - (problem[:newline_indent] + param_length + 1))
    new_ws = ' ' * new_ws_len

    if problem[:token].prev_token.type == :WHITESPACE
      problem[:token].prev_token.value = new_ws
    else
      index = tokens.index(problem[:token].prev_token)
      tokens.insert(index + 1, PuppetLint::Lexer::Token.new(:WHITESPACE, new_ws, 0, 0))
    end
  end
end
