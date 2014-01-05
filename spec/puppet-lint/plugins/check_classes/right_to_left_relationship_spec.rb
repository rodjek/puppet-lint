require 'spec_helper'

describe 'right_to_left_relationship' do
  let(:msg) { 'right-to-left (<-) relationship' }

  context 'chain 2 resources left to right' do
    let(:code) { "Class[foo] -> Class[bar]" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'chain 2 resources right to left' do
    let(:code) { "Class[foo] <- Class[bar]" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(12)
    end
  end
end
