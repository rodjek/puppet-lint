require 'spec_helper'

describe 'unquoted_node_name' do
  let(:msg) { 'unquoted node name found' }

  context 'with fix disabled' do
    context 'unquoted node name' do
      let(:code) { 'node foo { }' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(6)
      end
    end

    context 'default node' do
      let(:code) { 'node default { }' }

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'single quoted node name' do
      let(:code) { "node 'foo' { }" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'regex node name' do
      let(:code) { 'node /foo/ { }' }

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'multiple bare node names' do
      let(:code) { 'node foo, bar, baz { }' }

      it 'detects 3 problems' do
        expect(problems).to have(3).problems
      end

      it 'creates 3 warnings' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(6)
        expect(problems).to contain_warning(msg).on_line(1).in_column(11)
        expect(problems).to contain_warning(msg).on_line(1).in_column(16)
      end
    end

    context 'mixed node name types' do
      let(:code) { "node foo, 'bar', baz { }" }

      it 'detects 2 problems' do
        expect(problems).to have(2).problems
      end

      it 'creates 2 warnings' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(6)
        expect(problems).to contain_warning(msg).on_line(1).in_column(18)
      end
    end

    context 'multiple node blocks' do
      let(:code) { 'node foo { } node bar { }' }

      it 'detects 2 problems' do
        expect(problems).to have(2).problems
      end

      it 'creates 2 warnings' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(6)
        expect(problems).to contain_warning(msg).on_line(1).in_column(19)
      end
    end

    context 'incomplete node block' do
      let(:code) { 'node foo' }

      it 'detects a problem' do
        expect(problems).to have(1).problem
      end

      it 'creates 1 error' do
        expect(problems).to contain_error('Syntax error (try running `puppet parser validate <file>`)').on_line(1).in_column(1)
      end
    end
  end

  context 'with fix enabled' do
    before(:each) do
      PuppetLint.configuration.fix = true
    end

    after(:each) do
      PuppetLint.configuration.fix = false
    end

    context 'unquoted node name' do
      let(:code) { 'node foo { }' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(6)
      end

      it 'quotes the node name' do
        expect(manifest).to eq("node 'foo' { }")
      end
    end

    context 'multiple bare node names' do
      let(:code) { 'node foo, bar, baz { }' }
      let(:fixed) { "node 'foo', 'bar', 'baz' { }" }

      it 'detects 3 problems' do
        expect(problems).to have(3).problems
      end

      it 'fixes the 3 problems' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(6)
        expect(problems).to contain_fixed(msg).on_line(1).in_column(11)
        expect(problems).to contain_fixed(msg).on_line(1).in_column(16)
      end

      it 'quotes all three node names' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'mixed node name types' do
      let(:code) { "node foo, 'bar', baz { }" }
      let(:fixed) { "node 'foo', 'bar', 'baz' { }" }

      it 'detects 2 problems' do
        expect(problems).to have(2).problems
      end

      it 'fixes the 2 problems' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(6)
        expect(problems).to contain_fixed(msg).on_line(1).in_column(18)
      end

      it 'quotes the 2 unquoted node names' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
