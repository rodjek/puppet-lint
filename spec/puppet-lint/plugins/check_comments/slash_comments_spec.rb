require 'spec_helper'

describe 'slash_comments' do
  describe 'slash comments' do
    let(:code) { "// foo" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => '// comment found',
        :linenumber => 1,
        :column     => 1,
      })
    end
  end

  describe 'slash comments w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { '// foo' }

    its(:manifest) { should == '# foo' }
  end
end
