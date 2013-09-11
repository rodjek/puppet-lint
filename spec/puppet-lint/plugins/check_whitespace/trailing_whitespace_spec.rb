require 'spec_helper'

describe 'trailing_whitespace' do
  describe 'line with trailing whitespace' do
    let(:code) { "foo " }

    its(:problems) {
      should have_problem({
        :kind       => :error,
        :message    => 'trailing whitespace found',
        :linenumber => 1,
        :column     => 4,
      })
    }
  end

  describe 'single line with trailing whitespace w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "foo " }

    its(:problems) {
      should have_problem({
        :kind       => :fixed,
        :message    => 'trailing whitespace found',
        :linenumber => 1,
        :column     => 4,
      })
    }
    its(:manifest) { should == 'foo' }
  end

  describe 'multiple lines with trailing whitespace w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "foo    \nbar" }

    its(:problems) {
      should have_problem({
        :kind       => :fixed,
        :message    => 'trailing whitespace found',
        :linenumber => 1,
        :column     => 4,
      })
    }
    its(:manifest) { should == "foo\nbar" }
  end
end
