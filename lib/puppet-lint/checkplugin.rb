class PuppetLint::CheckPlugin
  # Public: Define a new lint check.
  #
  # name - The String name of the check.
  # b    - The Block implementation of the check.
  #
  # Returns nothing.
  def self.check(name, &b)
    PuppetLint.configuration.add_check(name, &b)
  end
end

