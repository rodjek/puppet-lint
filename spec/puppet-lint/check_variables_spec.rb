require 'spec_helper'

describe PuppetLint::Plugins::CheckVariables do
  subject do
    klass = described_class.new
    klass.test(defined?(path).nil? ? '' : path, code)
    klass
  end

  if Puppet.version.start_with? "2.7"
    describe 'a variable containing a dash' do
      let(:code) { "$foo-bar" }

      its(:warnings) { should include "Variable contains a dash on line 1" }
      its(:errors) { should be_empty }
    end
  end
end
