require 'spec_helper'

describe 'nested_classes_or_defines' do
  describe 'class on its own' do
    let(:code) { "class foo { }" }

    its(:problems) { should be_empty }
  end

  describe 'class inside a class' do
    let(:code) { "
      class foo {
        class bar {
        }
      }"
    }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "class defined inside a class",
        :linenumber => 3,
        :column     => 9,
      })
      should_not have_problem :kind => :error
    }
  end

  describe 'instantiating a parametised class inside a class' do
    let(:code) { "
      class bar {
        class { 'foo':
          bar => 'foobar'
        }
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'instantiating a parametised class inside a define' do
    let(:code) { "
      define bar() {
        class { 'foo':
          bar => 'foobar'
        }
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'define inside a class' do
    let(:code) { "
      class foo {
        define bar() {
        }
      }"
    }

  its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "define defined inside a class",
        :linenumber => 3,
        :column     => 9,
      })
      should_not have_problem :kind => :error
    }
  end
end
