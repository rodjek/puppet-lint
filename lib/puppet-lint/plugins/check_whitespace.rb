# Spacing, Identation & Whitespace
# http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace

class PuppetLint::Plugins::CheckWhitespace < PuppetLint::CheckPlugin
  check 'hard_tabs' do
    line_no = 0
    manifest_lines.each do |line|
      line_no += 1

      # MUST NOT use literal tab characters
      notify :error, :message =>  "tab character found", :linenumber => line_no if line.include? "\t"
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

      is_exception = false
      exceptions = [/(puppet):\/\//, /template\(.*\)/, / ?# ? \$Id:.*\$/ ]
      exceptions.each do |regex|
        if line =~ regex
          is_exception = true
          break
        end
      end

      # SHOULD NOT exceed an 80 character line width
      unless is_exception or line.scan(/./mu).size <= 80
        if line =~ /^ *#/
          notify :error, :message =>  "commented line has more than 80 characters", :linenumber => line_no
        else
          notify :warning, :message =>  "line has more than 80 characters", :linenumber => line_no
        end
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
