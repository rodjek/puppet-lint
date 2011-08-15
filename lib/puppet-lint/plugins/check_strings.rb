class PuppetLint::Plugins::CheckStrings < PuppetLint::CheckPlugin
  def test(data)
    line_no = 0
    data.each_line do |line|
      line_no += 1
      line.match(/"([^\\"]|\\\\|\\")*"/).to_a.each do |s|
        if s.start_with? '"'
          variable_found = false
          s.scan(/.\$./) do |w|
            if w.start_with? '\\'
              next
            elsif w.end_with? '{'
              variable_found = true
            else
              warn "variable not enclosed in {} on line #{line_no}"
            end
          end
          unless variable_found
            warn "double quoted string containing no variables on line #{line_no}"
          end
        end
      end

      line.match(/'.+?'/).to_a.each do |s|
        if s.start_with? "'"
          s.scan(/\$./) do |w|
            if w.end_with? '{'
              error "single quoted string containing a variable found on line #{line_no}"
            end
          end
        end
      end
    end
  end
end
