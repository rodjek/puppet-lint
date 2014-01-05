require 'spec_helper'

describe 'nested_classes_or_defines' do
  let(:class_msg) { 'class defined inside a class' }
  let(:define_msg) { 'defined type defined inside a class' }

  context 'class on its own' do
    let(:code) { "class foo { }" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class inside a class' do
    let(:code) { "
      class foo {
        class bar {
        }
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(class_msg).on_line(3).in_column(9)
    end
  end

  context 'instantiating a parametised class inside a class' do
    let(:code) { "
      class bar {
        class { 'foo':
          bar => 'foobar'
        }
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'instantiating a parametised class inside a define' do
    let(:code) { "
      define bar() {
        class { 'foo':
          bar => 'foobar'
        }
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define inside a class' do
    let(:code) { "
      class foo {
        define bar() {
        }
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problems
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(define_msg).on_line(3).in_column(9)
    end
  end
end
