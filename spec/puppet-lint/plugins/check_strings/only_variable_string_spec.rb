require 'spec_helper'

describe 'only_variable_string' do
  context 'with fix disabled' do
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

    describe 'string containing only a variable w/ ref' do
      let(:code) { '"${foo[0]}"' }

      its(:problems) {
        should only_have_problem({
          :kind => :warning,
          :message => 'string containing only a variable',
          :linenumber => 1,
          :column => 3,
        })
      }
    end

    describe 'string containing only a variable w/ lots of refs' do
      let(:code) { '"${foo[0][aoeuaoeu][bar][999]}"' }

      its(:problems) {
        should only_have_problem({
          :kind       => :warning,
          :message    => 'string containing only a variable',
          :linenumber => 1,
          :column     => 3,
        })
      }
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    describe 'string containing only a variable' do
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

    describe 'string contaiting only a variable w/ ref' do
      let(:code) { '"${foo[0]}"' }

      its(:problems) {
        should only_have_problem({
          :kind       => :fixed,
          :message    => 'string containing only a variable',
          :linenumber => 1,
          :column     => 3,
        })
      }

      its(:manifest) { should == "$foo[0]" }
    end

    describe 'string containing only a variable w/ lots of refs' do
      let(:code) { '"${foo[0][aoeuaoeu][bar][999]}"' }

      its(:problems) {
        should only_have_problem({
          :kind       => :fixed,
          :message    => 'string containing only a variable',
          :linenumber => 1,
          :column     => 3,
        })
      }

      its(:manifest) { should == "$foo[0][aoeuaoeu][bar][999]" }
    end
  end
end
