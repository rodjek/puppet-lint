# Spacing, Identation & Whitespace
# http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace

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

  check 'trailing_whitespace' do
    line_no = 0
    manifest_lines.each do |line|
      line_no += 1

      # MUST NOT contain trailing white space
      notify :error, :message =>  "trailing whitespace found", :linenumber => line_no if line.end_with? " "
    end
  end

  check '80chars' do
    line_no = 0
    manifest_lines.each do |line|
      line_no += 1

      # SHOULD NOT exceed an 80 character line width
      unless line =~ /puppet:\/\//
        notify :warning, :message =>  "line has more than 80 characters", :linenumber => line_no if line.scan(/./mu).size  > 80
      end
    end
  end

  check '2sp_soft_tabs' do
    line_no = 0
    manifest_lines.each do |line|
      line_no += 1

      # MUST use two-space soft tabs
      line.scan(/^ +/) do |prefix|
        unless prefix.length % 2 == 0
          notify :error, :message =>  "two-space soft tabs not used", :linenumber => line_no
        end
      end
    end
  end

  check 'arrow_alignment' do
    line_no = 0
    in_resource = false
    selectors = []
    resource_indent_length = 0
    manifest_lines.each do |line|
      line_no += 1

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
              notify :warning, :message =>  "=> on line isn't properly aligned for selector", :linenumber => line_no
            end

            # then for a new selector or selector finish
            if line.strip.end_with? "{"
              selectors.push(0)
            elsif line.strip =~ /\}[,;]?$/
              selectors.pop
            end
          else
            unless line_indent.length == resource_indent_length
              notify :warning, :message =>  "=> on line isn't properly aligned for resource", :linenumber => line_no
            end

            if line.strip.end_with? "{"
              selectors.push(0)
            end
          end
        else
          resource_indent_length = line_indent.length
          in_resource = true
          if line.strip.end_with? "{"
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
