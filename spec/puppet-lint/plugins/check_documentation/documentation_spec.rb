require 'spec_helper'

describe 'documentation' do
  let(:class_msg) { 'class not documented' }
  let(:define_msg) { 'defined type not documented' }

  describe 'undocumented class' do
    let(:code) { "class test {}" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(class_msg).on_line(1).in_column(1)
    end
  end

  describe 'documented class' do
    let(:code) { "
      # foo
      class test {}
    "}

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  describe 'undocumented defined type' do
    let(:code) { "define test {}" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(define_msg).on_line(1).in_column(1)
    end
  end

  describe 'documented defined type' do
    let(:code) { "
      # foo
      define test {}
    "}

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
