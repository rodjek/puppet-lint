require 'spec_helper'

describe PuppetLint::Plugins::CheckClasses do
  subject do
    klass = described_class.new
    klass.test(code)
    klass
  end

  describe 'chain 2 resources left to right' do
    let(:code) { "Class[foo] -> Class[bar]" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'chain 2 resources right to left' do
    let(:code) { "Class[foo] <- Class[bar]" }

    its(:warnings) { should include "right-to-left (<-) relationship on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'class on its own' do
    let(:code) { "class foo { }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'class inside a class' do
    let(:code) { "
      class foo {
        class bar {
        }
      }"
    }

    its(:warnings) { should include "class defined inside a class on line 3" }
    its(:errors) { should be_empty }
  end

  describe 'define inside a class' do
    let(:code) { "
      class foo {
        define bar() {
        }
      }"
    }

    its(:warnings) { should include "define defined inside a class on line 3" }
    its(:errors) { should be_empty }
  end

  describe 'class inheriting from its namespace' do
    let(:code) { "class foo::bar inherits foo { }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'class inheriting from another namespace' do
    let(:code) { "class foo::bar inherits baz { }" }

    its(:warnings) { should include "class inherits across namespaces on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'class with attrs in order' do
    let(:code) { "class foo($bar, $baz='gronk') { }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'class with attrs out of order' do
    let(:code) { "class foo($bar='baz', $gronk) { }" }

    its(:warnings) { should include "optional parameter listed before required parameter on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'define with attrs in order' do
    let(:code) { "define foo($bar, $baz='gronk') { }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'define with attrs out of order' do
    let(:code) { "define foo($bar='baz', $gronk) { }" }

    its(:warnings) { should include "optional parameter listed before required parameter on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'class with no variables declared accessing top scope' do
    let(:code) { "
      class foo {
        $bar = $baz
      }"
    }

    its(:warnings) { should include "top-scope variable being used without an explicit namespace on line 3" }
    its(:errors) { should be_empty}
  end

  describe 'class with no variables declared accessing top scope explicitly' do
    let(:code) { "
      class foo {
        $bar = $::baz
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'class with variables declared accessing local scope' do
    let(:code) { "
      class foo {
        $bar = 1
        $baz = $bar
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'class with parameters accessing local scope' do
    let(:code) { "
      class foo($bar) {
        $baz = $bar
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'defined type with no variables declared accessing top scope' do
    let(:code) { "
      define foo() {
        $bar = $fqdn
      }"
    }

    its(:warnings) { should include "top-scope variable being used without an explicit namespace on line 3" }
    its(:errors) { should be_empty }
  end

  describe 'defined type with no variables declared accessing top scope explicitly' do
    let(:code) { "
      define foo() {
        $bar = $::fqdn
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe '$name should be auto defined' do
    let(:code) { "
      define foo() {
        $bar = $name
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'instantiating a parametised class inside a class' do
    let(:code) { "
      class bar {
        class { 'foo':
          bar => 'foobar'
        }
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'instantiating a parametised class inside a define' do
    let(:code) { "
      define bar() {
        class { 'foo':
          bar => 'foobar'
        }
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end
end
