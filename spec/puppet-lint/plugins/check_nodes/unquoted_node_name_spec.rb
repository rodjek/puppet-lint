require 'spec_helper'

describe 'unquoted_node_name' do
  context 'with fix disabled' do
    describe 'unquoted node name' do
      let(:code) { "node foo { }" }

      its(:problems) {
        should have_problem({
          :kind       => :warning,
          :message    => 'unquoted node name found',
          :linenumber => 1,
          :column     => 6,
        })
      }
    end

    describe 'default node' do
      let(:code) { "node default { }" }

      its(:problems) { should be_empty }
    end

    describe 'single quoted node name' do
      let(:code) { "node 'foo' { }" }

      its(:problems) { should be_empty }
    end

    describe 'regex node name' do
      let(:code) { "node /foo/ { }" }

      its(:problems) { should be_empty }
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    describe 'unquoted node name' do
      let(:code) { "node foo { }" }

      its(:problems) {
        should have_problem({
          :kind       => :fixed,
          :message    => 'unquoted node name found',
          :linenumber => 1,
          :column     => 6,
        })
      }

      its(:manifest) { should eq("node 'foo' { }") }
    end
  end
end
