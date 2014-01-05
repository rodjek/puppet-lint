require 'spec_helper'

describe '2sp_soft_tabs' do
  let(:msg) { 'two-space soft tabs not used' }

  context 'when a line is indented by 3 spaces' do
    let(:code) { "
      file { 'foo':
         foo => bar,
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(3).in_column(1)
    end
  end
end
