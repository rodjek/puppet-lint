class PuppetLint::Plugins::CheckVariables < PuppetLint::CheckPlugin
  def test(data)
    lexer = Puppet::Parser::Lexer.new
    lexer.string = data
    tokens = lexer.fullscan

    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :VARIABLE
        variable = token.last[:value]
        line_no = token.last[:line]
        if variable.match(/-/)
          warn "Variable contains a dash on line #{line_no}"
        end
      end
    end
  end
end
