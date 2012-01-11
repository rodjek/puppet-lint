class PuppetLint::Plugins::CheckVariables < PuppetLint::CheckPlugin
  check 'variable_contains_dash' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :VARIABLE
        variable = token.last[:value]
        line_no = token.last[:line]
        if variable.match(/-/)
          notify :warning, :message =>  "variable contains a dash", :linenumber => line_no
        end
      end

      if token.first == :DQPRE
        end_of_string_idx = tokens[token_idx..-1].index { |r| r.first == :DQPOST }
        tokens[token_idx..end_of_string_idx].each do |t|
          if t.first == :VARIABLE and t.last[:value].match(/-/)
            notify :warning, :message =>  "variable contains a dash", :linenumber => t.last[:line]
          end
        end
      end
    end
  end
end
