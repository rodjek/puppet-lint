class PuppetLint::Plugins::CheckWhitespace < PuppetLint::CheckPlugin
  def test(data)
    line_no = 0
    data.each_line do |line|
      line_no += 1
      warn "tab character found on line #{line_no}" if line.include? "\t"
      warn "trailing whitespace found on line #{line_no}" if line.end_with? " "
    end
  end
end
