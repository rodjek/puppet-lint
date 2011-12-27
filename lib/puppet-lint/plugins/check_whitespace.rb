# Spacing, Identation & Whitespace
# http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace

class PuppetLint::Plugins::CheckWhitespace < PuppetLint::CheckPlugin
  def test(path, data)
    line_no = 0
    in_resource = false
    selectors = []
    resource_indent_length = 0
    data.split("\n").each do |line|
      line_no += 1

      # MUST NOT use literal tab characters
      error "tab character found on line #{line_no}" if line.include? "\t"

      # MUST NOT contain trailing white space
      error "trailing whitespace found on line #{line_no}" if line.end_with? " "

      # SHOULD NOT exceed an 80 character line width
      unless line =~ /puppet:\/\//
        warn "line #{line_no} has more than 80 characters" if line.length > 80
      end

      # MUST use two-space soft tabs
      line.scan(/^ +/) do |prefix|
        unless prefix.length % 2 == 0
          error "two-space soft tabs not used on line #{line_no}"
        end
      end

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
              warn "=> on line #{line_no} isn't properly aligned for selector"
            end

            # then for a new selector or selector finish
            if line.strip.end_with? "{"
              selectors.push(0)
            elsif line.strip =~ /\}[,;]?$/
              selectors.pop
            end
          else
            unless line_indent.length == resource_indent_length
              warn "=> on line #{line_no} isn't properly aligned for resource"
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
