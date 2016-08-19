require 'spec_helper'

describe 'variables_not_enclosed' do
  let(:msg) { 'variable not enclosed in {}' }

  context 'with fix disabled' do
    context 'variable not enclosed in {}' do
      let(:code) { '" $gronk"' }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(3)
      end
    end

    context 'variable not enclosed in {} after many tokens' do
      let(:code) { ("'groovy'\n" * 20) + '" $gronk"' }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(21).in_column(3)
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

    context 'variable not enclosed in {}' do
      let(:code) { '" $gronk"' }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(3)
      end

      it 'should enclose the variable in braces' do
        expect(manifest).to eq('" ${gronk}"')
      end
    end

    context 'variable not enclosed in {} after many tokens' do
      let(:code) { ("'groovy'\n" * 20) + '" $gronk"' }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(21).in_column(3)
      end

      it 'should enclose the variable in braces' do
        expect(manifest).to eq(("'groovy'\n" * 20) + '" ${gronk}"')
      end
    end
  end
end
