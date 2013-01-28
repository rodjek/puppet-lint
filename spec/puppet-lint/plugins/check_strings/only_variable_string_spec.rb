require 'spec_helper'

describe 'only_variable_string' do
  describe 'string containing only a variable' do
    let(:code) { '"${foo}"' }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => 'string containing only a variable',
        :linenumber => 1,
        :column     => 3,
      })
    }
  end

  describe 'string containing only a variable w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { '"${foo}"' }

    its(:problems) {
      should only_have_problem({
        :kind       => :fixed,
        :message    => 'string containing only a variable',
        :linenumber => 1,
        :column     => 3,
      })
    }

    its(:manifest) { should == "$foo" }
  end
end
