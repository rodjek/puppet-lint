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

  # Check the raw manifest strings for any arrows (=>) in a grouping ({}) that
  # are not aligned with other arrows in that grouping.
  #
  # Returns nothing.
  check 'arrow_alignment' do
    in_resource = false
    selectors = []
    resource_indent_length = 0
    manifest_lines.each_with_index do |line, idx|
      # SHOULD align fat comma arrows (=>) within blocks of attributes
      if line =~ /^( +.+? +)=>/
        line_indent = $1
        if in_resource
          if selectors.count > 0
            if selectors.last == 0
              selectors[-1] = line_indent.length
            end

            # check for length first
            unless line_indent.length == selectors.last
              notify :warning, {
                :message    => '=> is not properly aligned for selector',
                :linenumber => idx + 1,
                :column     => line_indent.length,
              }
            end

            # then for a new selector or selector finish
            if line.strip.end_with? '{'
              selectors.push(0)
            elsif line.strip =~ /\}[,;]?$/
              selectors.pop
            end
          else
            unless line_indent.length == resource_indent_length
              notify :warning, {
                :message    => '=> is not properly aligned for resource',
                :linenumber => idx + 1,
                :column     => line_indent.length,
              }
            end

            if line.strip.end_with? '{'
              selectors.push(0)
            end
          end
        else
          resource_indent_length = line_indent.length
          in_resource = true
          if line.strip.end_with? '{'
            selectors.push(0)
          end
        end
      elsif line.strip =~ /\}[,;]?$/ and selectors.count > 0
        selectors.pop
      else
        in_resource = false
        resource_indent_length = 0
      end
    end
  end
end
