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

  # Public: Define a new check helper method.
  #
  # name - The String name of the helper.
  # b    - The Block implementation of the helper.
  #
  # Returns nothing.
  def self.helper(name, &b)
    PuppetLint.configuration.add_helper(name, &b)
  end
end

