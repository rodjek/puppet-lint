require 'spec_helper'

describe PuppetLint::Plugins::CheckDebug do
  subject do
    klass = described_class.new
    klass.run(defined?(path).nil? ? '' : path, code)
    klass
  end

  ## dont really know what can be checked here :)
  
end