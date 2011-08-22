require 'spec_helper'

describe PuppetLint::Plugins::CheckClasses do
  subject do
    klass = described_class.new
    klass.test(code)
    klass
  end

  describe 'chain 2 resources left to right' do
    let(:code) { "Class[foo] -> Class[bar]" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'chain 2 resources right to left' do
    let(:code) { "Class[foo] <- Class[bar]" }

    its(:warnings) { should include "right-to-left (<-) relationship on line 1" }
    its(:errors) { should be_empty }
  end
end
