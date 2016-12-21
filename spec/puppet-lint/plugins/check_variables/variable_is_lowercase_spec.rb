require 'spec_helper'

describe 'variable_is_lowercase' do
  let(:msg) { 'variable contains an uppercase letter' }

  context 'a variable containing an uppercase letter' do
    let(:code) { '$fooBar' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end
  
    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(1)
    end
  end

  context 'a variable containing only lowercase letters' do
    let(:code) { '$foobar' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
