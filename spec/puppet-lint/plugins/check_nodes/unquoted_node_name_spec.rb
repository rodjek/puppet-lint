require 'spec_helper'

describe 'unquoted_node_name' do
  let(:msg) { 'unquoted node name found' }

  context 'with fix disabled' do
    context 'unquoted node name' do
      let(:code) { "node foo { }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(6)
      end
    end

    context 'default node' do
      let(:code) { "node default { }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'single quoted node name' do
      let(:code) { "node 'foo' { }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'regex node name' do
      let(:code) { "node /foo/ { }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'unquoted node name' do
      let(:code) { "node foo { }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(6)
      end

      it 'should quote the node name' do
        expect(manifest).to eq("node 'foo' { }")
      end
    end
  end
end
