require 'spec_helper'

describe 'slash_comments' do
  let(:msg) { '// comment found' }

  context 'with fix disabled' do
    context 'slash comments' do
      let(:code) { '// foo' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(1)
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

    context 'slash comments' do
      let(:code) { '// foo' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'replaces the double slash with a hash' do
        expect(manifest).to eq('# foo')
      end
    end
  end
end
