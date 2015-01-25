require 'spec_helper'

describe 'trailing_whitespace' do
  let(:msg) { 'trailing whitespace found' }

  context 'with fix disabled' do
    context 'line with trailing whitespace' do
      let(:code) { "foo " }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create an error' do
        expect(problems).to contain_error(msg).on_line(1).in_column(4)
      end
    end

    context 'line without code and trailing whitespace' do
      let(:code) { "
class {
  
}
" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create an error' do
        expect(problems).to contain_error(msg).on_line(3).in_column(1)
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

    context 'single line with trailing whitespace' do
      let(:code) { "foo " }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(4)
      end

      it 'should remove the trailing whitespace' do
        expect(manifest).to eq('foo')
      end
    end

    context 'multiple lines with trailing whitespace' do
      let(:code) { "foo    \nbar" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(4)
      end

      it 'should remove the trailing whitespace' do
        expect(manifest).to eq("foo\nbar")
      end
    end

    context 'line without code and trailing whitespace' do
      let(:code) { "
class foo {
  
}
" }
      let(:fixed) { "
class foo {

}
" }
      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create an error' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(1)
      end

      it 'should remove the trailing whitespace' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
