# Public: Check the raw manifest string for lines containing hard tab
# characters and record an error for each instance found.
PuppetLint.new_check(:hard_tabs) do
  def check
    tokens.select { |r|
      [:INDENT, :WHITESPACE].include?(r.type) && r.value.include?("\t")
    }.each do |token|
      notify :error, {
        :message    => 'tab character found',
        :linenumber => token.line,
        :column     => token.column,
        :token      => token,
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
      token.type == :WHITESPACE
    }.select { |token|
      token.next_token.nil? || token.next_token.type == :NEWLINE
    }.each do |token|
      notify :error, {
        :message    => 'trailing whitespace found',
        :linenumber => token.line,
        :column     => token.column,
        :token      => token,
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

# Public: Test the raw manifest string for lines containing more than 80
# characters and record a warning for each instance found.  The only exceptions
# to this rule are lines containing URLs and template() calls which would hurt
# readability if split.
PuppetLint.new_check(:'80chars') do
  def check
    manifest_lines.each_with_index do |line, idx|
      unless line =~ /:\/\// || line =~ /template\(/
        if line.scan(/./mu).size > 80
          notify :warning, {
            :message    => 'line has more than 80 characters',
            :linenumber => idx + 1,
            :column     => 80,
          }
        end
      end
    end
  end
end

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
        :message    => 'two-space soft tabs not used',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end

# Public: Check the manifest tokens for any arrows (=>) in a grouping ({}) that
# are not aligned with other arrows in that grouping.
PuppetLint.new_check(:arrow_alignment) do
  def check
    resource_indexes.each do |res_idx|
      indent_depth = [0]
      indent_depth_idx = 0
      resource_tokens = tokens[res_idx[:start]..res_idx[:end]]
      resource_tokens.reject! do |token|
        {:COMMENT => true, :SLASH_COMMENT => true, :MLCOMMENT => true}.include? token.type
      end

      # If this is a single line resource, skip it
      first_arrow = resource_tokens.index { |r| r.type == :FARROW }
      last_arrow = resource_tokens.rindex { |r| r.type == :FARROW }
      next if first_arrow.nil?
      next if last_arrow.nil?
      next unless resource_tokens[first_arrow..last_arrow].any? { |r| r.type == :NEWLINE }

      resource_tokens.each_with_index do |token, idx|
        if token.type == :FARROW
          indent_length = token.column

          if indent_depth[indent_depth_idx] < indent_length
            indent_depth[indent_depth_idx] = indent_length
          end

        elsif token.type == :LBRACE
          indent_depth_idx += 1
          indent_depth << 0
        elsif token.type == :RBRACE
          indent_depth_idx -= 1
        end
      end

      indent_depth_idx = 0
      resource_tokens.each_with_index do |token, idx|
        if token.type == :FARROW
          indent_length = token.column
          unless indent_depth[indent_depth_idx] == indent_length
            notify :warning, {
              :message      => 'indentation of => is not properly aligned',
              :linenumber   => token.line,
              :column       => token.column,
              :token        => token,
              :indent_depth => indent_depth[indent_depth_idx],
            }
          end
        elsif token.type == :LBRACE
          indent_depth_idx += 1
        elsif token.type == :RBRACE
          indent_depth_idx -= 1
        end
      end
    end
  end

  def fix(problem)
    offset = problem[:indent_depth] - problem[:token].column
    problem[:token].prev_token.value = problem[:token].prev_token.value + (' ' * offset)
  end
end
