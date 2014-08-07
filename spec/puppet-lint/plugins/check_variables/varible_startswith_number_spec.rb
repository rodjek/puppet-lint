require 'spec_helper'

describe 'variable_startswith_number' do
  let(:msg) { 'variable starts with a number' }

  context 'a variable starting with a number' do
    let(:code) { '$1foo' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(1)
    end
  end

  context 'variable starting with a number' do
    let(:code) { '" $1foo"' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(3)
    end
  end

  context 'variable containing a number ' do
    let(:code) { "$foo1" }

    it 'should not detect any problems' do
      expect(problems).to be_empty
    end
  end
end
