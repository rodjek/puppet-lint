# Public: Check the raw manifest string for lines containing hard tab
# characters and record an error for each instance found.
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
PuppetLint.new_check(:arrow_alignment) do
  COMMENT_TYPES = Set[:COMMENT, :SLASH_COMMENT, :MLCOMMENT]

  def check
    resource_indexes.each do |res_idx|
      indent_depth = [0]
      indent_depth_idx = 0
      level_tokens = []
      resource_tokens = res_idx[:tokens]
      resource_tokens.reject! do |token|
        COMMENT_TYPES.include? token.type
      end

      # If this is a single line resource, skip it
      first_arrow = resource_tokens.index { |r| r.type == :FARROW }
      last_arrow = resource_tokens.rindex { |r| r.type == :FARROW }
      next if first_arrow.nil?
      next if last_arrow.nil?
      next unless resource_tokens[first_arrow..last_arrow].any? { |r| r.type == :NEWLINE }

      resource_tokens.each_with_index do |token, idx|
        if token.type == :FARROW
          (level_tokens[indent_depth_idx] ||= []) << token
          prev_indent_token = resource_tokens[0..idx].rindex { |t| t.type == :INDENT }
          indent_token_length = prev_indent_token.nil? ? 0 : resource_tokens[prev_indent_token].to_manifest.length
          indent_length = indent_token_length + token.prev_code_token.to_manifest.length + 2

          if indent_depth[indent_depth_idx] < indent_length
            indent_depth[indent_depth_idx] = indent_length
          end

        elsif token.type == :LBRACE
          indent_depth_idx += 1
          indent_depth << 0
          level_tokens[indent_depth_idx] ||= []
        elsif token.type == :RBRACE || token.type == :SEMIC
          level_tokens[indent_depth_idx].each do |arrow_tok|
            unless arrow_tok.column == indent_depth[indent_depth_idx] || level_tokens[indent_depth_idx].size == 1
              arrows_on_line = level_tokens[indent_depth_idx].select { |t| t.line == arrow_tok.line }
              notify :warning, {
                :message        => "indentation of => is not properly aligned (expected in column #{indent_depth[indent_depth_idx]}, but found it in column #{arrow_tok.column})",
                :line           => arrow_tok.line,
                :column         => arrow_tok.column,
                :token          => arrow_tok,
                :indent_depth   => indent_depth[indent_depth_idx],
                :newline        => !(arrows_on_line.index(arrow_tok) == 0),
                :newline_indent => arrows_on_line.first.prev_code_token.prev_token.value,
              }
            end
          end
          indent_depth[indent_depth_idx] = 0
          level_tokens[indent_depth_idx].clear
          indent_depth_idx -= 1
        end
      end
    end
  end

  def fix(problem)
    new_ws_len = (problem[:indent_depth] - (problem[:newline_indent].length + problem[:token].prev_code_token.to_manifest.length + 1))
    new_ws = ' ' * new_ws_len
    if problem[:newline]
      index = tokens.index(problem[:token].prev_code_token.prev_token)

      #insert newline
      tokens.insert(index, PuppetLint::Lexer::Token.new(:NEWLINE, "\n", 0, 0))

      # indent the parameter to the correct depth
      problem[:token].prev_code_token.prev_token.type = :INDENT
      problem[:token].prev_code_token.prev_token.value = problem[:newline_indent].dup
    end

    if problem[:token].prev_token.type == :WHITESPACE
      problem[:token].prev_token.value = new_ws
    else
      index = tokens.index(problem[:token].prev_token)
      tokens.insert(index + 1, PuppetLint::Lexer::Token.new(:WHITESPACE, new_ws, 0, 0))
    end
  end
end
