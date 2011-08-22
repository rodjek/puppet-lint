class PuppetLint::Plugins::CheckClasses < PuppetLint::CheckPlugin
  def test(data)
    lexer = Puppet::Parser::Lexer.new
    lexer.string = data
    tokens = lexer.fullscan

    tokens.select { |r| r.first == :OUT_EDGE }.each do |token|
      warn "right-to-left (<-) relationship on line #{token.last[:line]}"
    end
  end
end
