class PuppetLint::Plugins::CheckWhitespace < PuppetLint::CheckPlugin
  def test(data)
    line_no = 0
    data.split("\n").each do |line|
      line_no += 1
      error "tab character found on line #{line_no}" if line.include? "\t"
      error "trailing whitespace found on line #{line_no}" if line.end_with? " "
      warn "line #{line_no} has more than 80 characters" if line.length > 80

      line.scan(/^ +/) do |prefix|
        unless prefix.length % 2 == 0
          error "two-space soft tabs not used on line #{line_no}"
        end
      end
    end
  end
end
