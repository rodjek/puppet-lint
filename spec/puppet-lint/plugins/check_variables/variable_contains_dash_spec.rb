require 'spec_helper'

describe 'variable_contains_dash' do
  let(:msg) { 'variable contains a dash' }

  context 'a variable containing a dash' do
    let(:code) { '$foo-bar' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(1)
    end
  end

  context 'variable containing a dash' do
    let(:code) { '" $foo-bar"' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(3)
    end
  end

  context 'variable with an array reference containing a dash' do
    let(:code) { "$foo[bar-baz]" }

    it 'should not detect any problems' do
      expect(problems).to be_empty
    end
  end

  context 'enclosed variable in a string followed by a dash' do
    let(:code) { '"${variable}-is-ok"' }

    it 'should not detect any problems' do
      expect(problems).to be_empty
    end
  end
end
