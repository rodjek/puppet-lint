require 'spec_helper'

describe 'variable_contains_upcase' do
  let(:msg) { 'variable contains a capital letter' }

  context 'a variable containing a capital' do
    let(:code) { '$fOobar' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(1)
    end
  end

  context 'variable containing a capital' do
    let(:code) { '" $fOobar"' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(3)
    end
  end
end
