require 'spec_helper'

describe 'hard_tabs' do
  describe 'hard tabs indents' do
    let(:code) { "\tfoo => bar," }

    its(:problems) {
      should have_problem({
        :kind       => :error,
        :message    => 'tab character found',
        :linenumber => 1,
        :column     => 1,
      })
    }
  end

  describe 'hard tabs indents' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "\tfoo => bar," }

    its(:problems) {
      should have_problem({
        :kind       => :fixed,
        :message    => 'tab character found',
        :linenumber => 1,
        :column     => 1,
      })
    }
    its(:manifest) { should == "  foo => bar," }
  end
end
