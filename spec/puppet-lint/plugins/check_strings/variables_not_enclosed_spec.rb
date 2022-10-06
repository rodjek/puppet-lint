require 'spec_helper'

describe 'variables_not_enclosed' do
  let(:msg) { 'variable not enclosed in {}' }

  context 'with fix disabled' do
    context 'variable not enclosed in {}' do
      let(:code) { '" $gronk"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(3)
      end
    end

    context 'variable not enclosed in {} after many tokens' do
      let(:code) { ("'groovy'\n" * 20) + '" $gronk"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(21).in_column(3)
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

    context 'variable not enclosed in {}' do
      let(:code) { '" $gronk"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(3)
      end

      it 'encloses the variable in braces' do
        expect(manifest).to eq('" ${gronk}"')
      end
    end

    context 'variable not enclosed in {} after many tokens' do
      let(:code) { ("'groovy'\n" * 20) + '" $gronk"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(21).in_column(3)
      end

      it 'encloses the variable in braces' do
        expect(manifest).to eq(("'groovy'\n" * 20) + '" ${gronk}"')
      end
    end

    context 'variables not enclosed in {}, delimited by -' do
      let(:code) { '"$foo-$bar"' }

      it 'only detects two problems' do
        expect(problems).to have(2).problems
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(2)
        expect(problems).to contain_fixed(msg).on_line(1).in_column(7)
      end

      it 'encloses both variables in braces' do
        expect(manifest).to eq('"${foo}-${bar}"')
      end
    end

    context 'variable with a hash or array reference not enclosed' do
      let(:code) { %("$foo['bar'][2]something") }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(2)
      end

      it 'encloses the variable with the references' do
        expect(manifest).to eq(%("${foo['bar'][2]}something"))
      end
    end

    context 'unenclosed variable followed by a dash and then text' do
      let(:code) { '"$hostname-keystore"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(2)
      end

      it 'encloses the variable but not the text' do
        expect(manifest).to eq('"${hostname}-keystore"')
      end
    end
  end
end
