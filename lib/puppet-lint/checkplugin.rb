class PuppetLint::CheckPlugin
  def self.check(name, &b)
    PuppetLint.configuration.add_check(name, &b)
  end
end

