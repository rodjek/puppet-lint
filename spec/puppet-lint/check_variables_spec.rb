require 'spec_helper'

describe PuppetLint::Plugins::CheckVariables do
  subject do
    klass = described_class.new
    klass.test(code)
    klass
  end

  describe 'a variable containing a dash' do
    let(:code) { "$foo-bar" }

    its(:warnings) { should include "Variable contains a dash on line 1" }
    its(:errors) { should be_empty }
  end

end
