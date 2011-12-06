# Spacing, Identation & Whitespace
# http://http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace

class PuppetLint::Plugins::CheckWhitespace < PuppetLint::CheckPlugin
  def test(path, data)
    line_no = 0
    in_resource = false
    in_selector = false
    resource_indent_length = 0
    selector_indent_length = 0
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
      if in_selector
        if line.strip =~ /\}[,;]?$/
          in_selector = false
          selector_indent_length = 0
        end
      end

      if line =~ /^( +\w+ +)=>/
        line_indent = $1
        if in_resource
          if in_selector
            if selector_indent_length == 0
              selector_indent_length = line_indent.length
            end

            unless line_indent.length == selector_indent_length
              warn "=> on line #{line_no} isn't aligned with the previous line"
            end

            if line.strip =~ /\}[,;]?$/
              in_selector = false
              selector_indent_length = 0
            end
          else
            if line.strip.end_with? "{"
              in_selector = true
            end
            unless line_indent.length == resource_indent_length
              warn "=> on line #{line_no} isn't aligned with the previous line"
            end
          end
        else
          resource_indent_length = line_indent.length
          in_resource = true
          if line.strip.end_with? "{"
            in_selector = true
          end
        end
      else
        in_resource = false
        resource_indent_length = 0
      end
    end
  end
end
