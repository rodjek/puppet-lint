require 'spec_helper'

describe 'hard_tabs' do
  let(:msg) { 'tab character found' }

  context 'with fix disabled' do
    context 'hard tabs indents' do
      let(:code) { "\tfoo => bar," }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates an error' do
        expect(problems).to contain_error(msg).on_line(1).in_column(1)
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

    context 'hard tabs indents' do
      let(:code) { "\tfoo => bar," }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'converts the tab characters into spaces' do
        expect(manifest).to eq('  foo => bar,')
      end
    end
  end
end
