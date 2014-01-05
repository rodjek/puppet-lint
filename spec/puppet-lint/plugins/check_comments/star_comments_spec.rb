require 'spec_helper'

describe 'star_comments' do
  let(:msg) { '/* */ comment found' }

  context 'slash asterisk comment' do
    let(:code) { "
      /* foo
      */
    "}

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(7)
    end
  end
end
