class PuppetLint::Plugins::CheckWhitespace < PuppetLint::CheckPlugin
  # Check the raw manifest string for lines containing hard tab characters and
  # record an error for each instance found.
  #
  # Returns nothing.
  check 'hard_tabs' do
    manifest_lines.each_with_index do |line, idx|
      if line.include? "\t"
        notify :error, {
          :message    => 'tab character found',
          :linenumber => idx + 1,
          :column     => line.index("\t") + 1,
        }
      end
    end
  end

  # Check the raw manifest string for lines ending with whitespace and record
  # an error for each instance found.
  #
  # Returns nothing.
  check 'trailing_whitespace' do
    manifest_lines.each_with_index do |line, idx|
      if line.end_with? ' '
        notify :error, {
          :message    => 'trailing whitespace found',
          :linenumber => idx + 1,
          :column     => line.rindex(' ') + 1,
        }
      end
    end
  end

  # Test the raw manifest string for lines containing more than 80 characters
  # and record a warning for each instance found.  The only exception to this
  # rule is lines containing puppet:// URLs which would hurt readability if
  # split.
  #
  # Returns nothing.
  check '80chars' do
    manifest_lines.each_with_index do |line, idx|
      unless line =~ /puppet:\/\//
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

  # Check the manifest tokens for any indentation not using 2 space soft tabs
  # and record an error for each instance found.
  #
  # Returns nothing.
  check '2sp_soft_tabs' do
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

  # Check the manifest tokens for any arrows (=>) in a grouping ({}) that are
  # not aligned with other arrows in that grouping.
  #
  # Returns nothing.
  check 'arrow_alignment' do
    resource_indexes.each do |res_idx|
      indent_depth = [nil]
      resource_tokens = tokens[res_idx[:start]..res_idx[:end]]
      resource_tokens.reject! do |token|
        {:COMMENT => true, :SLASH_COMMENT => true, :MLCOMMENT => true}.include? token.type
      end

      # If this is a single line resource, skip it
      next if resource_tokens.select { |r| r.type == :NEWLINE }.empty?

      resource_tokens.each_with_index do |token, idx|
        if token.type == :FARROW
          indent_length = token.column

          if indent_depth.last.nil?
            indent_depth[-1] = indent_length
          end

          unless indent_depth.last == indent_length
            notify :warning, {
              :message    => 'indentation of => is not properly aligned',
              :linenumber => token.line,
              :column     => token.column,
            }
          end
        elsif token.type == :LBRACE
          indent_depth.push(nil)
        elsif token.type == :RBRACE
          indent_depth.pop
        end
      end
    end
  end
end
