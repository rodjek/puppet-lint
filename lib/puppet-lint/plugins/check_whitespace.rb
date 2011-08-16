# Spacing, Identation & Whitespace
# http://http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace

class PuppetLint::Plugins::CheckWhitespace < PuppetLint::CheckPlugin
  def test(data)
    line_no = 0
    in_block = false
    prefix_length = 0
    data.split("\n").each do |line|
      line_no += 1

      # MUST NOT use literal tab characters
      error "tab character found on line #{line_no}" if line.include? "\t"

      # MUST NOT contain trailing white space
      error "trailing whitespace found on line #{line_no}" if line.end_with? " "

      # SHOULD NOT exceed an 80 character line width
      warn "line #{line_no} has more than 80 characters" if line.length > 80

      # MUST use two-space soft tabs
      line.scan(/^ +/) do |prefix|
        unless prefix.length % 2 == 0
          error "two-space soft tabs not used on line #{line_no}"
        end
      end

      # SHOULD align fat comma arrows (=>) within blocks of attributes
      if line =~ /^( +\w+ +)=>/
        if in_block
          unless $1.length == prefix_length
            warn "=> on line #{line_no} isn't aligned with the previous line"
          end
        else
          prefix_length = $1.length
          in_block = true
        end
      else
        in_block = false
        prefix_length = 0
      end
    end
  end
end
