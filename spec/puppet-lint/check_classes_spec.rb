require 'spec_helper'

describe PuppetLint::Plugins::CheckClasses do
  subject do
    klass = described_class.new
    klass.run(defined?(path).nil? ? '' : path, code)
    klass
  end

  describe 'chain 2 resources left to right' do
    let(:code) { "Class[foo] -> Class[bar]" }

    its(:problems) { should be_empty }
  end

  describe 'chain 2 resources right to left' do
    let(:code) { "Class[foo] <- Class[bar]" }

    its(:problems) {
      should have_problem :kind => :warning, :message => "right-to-left (<-) relationship", :linenumber => 1
      should_not have_problem :kind => :error
    }
  end

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
      should have_problem :kind => :warning, :message => "class defined inside a class", :linenumber => 3
      should_not have_problem :kind => :error
    }
  end

  describe 'define inside a class' do
    let(:code) { "
      class foo {
        define bar() {
        }
      }"
    }

  its(:problems) {
      should have_problem :kind => :warning, :message => "define defined inside a class", :linenumber => 3
      should_not have_problem :kind => :error
    }
  end

  describe 'class inheriting from its namespace' do
    let(:code) { "class foo::bar inherits foo { }" }

    its(:problems) { should be_empty }
  end

  describe 'class inheriting from another namespace' do
    let(:code) { "class foo::bar inherits baz { }" }

    its(:problems) {
      should have_problem :kind => :warning, :message => "class inherits across namespaces", :linenumber => 1
      should_not have_problem :kind => :error
    }
  end

  describe 'class with attrs in order' do
    let(:code) { "class foo($bar, $baz='gronk') { }" }

    its(:problems) { should be_empty }
  end

  describe 'class with attrs out of order' do
    let(:code) { "class foo($bar='baz', $gronk) { }" }

    its(:problems) {
      should have_problem :kind => :warning, :message => "optional parameter listed before required parameter", :linenumber => 1
      should_not have_problem :kind => :error
    }
  end

  describe 'define with attrs in order' do
    let(:code) { "define foo($bar, $baz='gronk') { }" }

    its(:problems) { should be_empty }
  end

  describe 'define with attrs out of order' do
    let(:code) { "define foo($bar='baz', $gronk) { }" }

    its(:problems) {
      should have_problem :kind => :warning, :message => "optional parameter listed before required parameter", :linenumber => 1
      should_not have_problem :kind => :error
    }
  end

  describe 'class with no variables declared accessing top scope' do
    let(:code) { "
      class foo {
        $bar = $baz
      }"
    }

    its(:problems) {
      should have_problem :kind => :warning, :message => "top-scope variable being used without an explicit namespace", :linenumber => 3
      should_not have_problem :kind => :error
    }
  end

  describe 'class with no variables declared accessing top scope explicitly' do
    let(:code) { "
      class foo {
        $bar = $::baz
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'class with variables declared accessing local scope' do
    let(:code) { "
      class foo {
        $bar = 1
        $baz = $bar
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'class with parameters accessing local scope' do
    let(:code) { "
      class foo($bar) {
        $baz = $bar
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'defined type with no variables declared accessing top scope' do
    let(:code) { "
      define foo() {
        $bar = $fqdn
      }"
    }

    its(:problems) {
      should have_problem :kind => :warning, :message => "top-scope variable being used without an explicit namespace", :linenumber => 3
      should_not have_problem :kind => :error
    }
  end

  describe 'defined type with no variables declared accessing top scope explicitly' do
    let(:code) { "
      define foo() {
        $bar = $::fqdn
      }"
    }

    its(:problems) { should be_empty }
  end

  describe '$name should be auto defined' do
    let(:code) { "
      define foo() {
        $bar = $name
        $baz = $title
        $gronk = $module_name
        $meep = $1
      }"
    }

    its(:problems) { should be_empty }
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

  describe 'class/define parameter set to another variable' do
    let(:code) { "
      define foo($bar, $baz = $name, $gronk=$::fqdn) {
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'class/define parameter set to another variable with incorrect order' do
    let(:code) { "
      define foo($baz = $name, $bar, $gronk=$::fqdn) {
      }"
    }

    its(:problems) {
      should have_problem :kind => :warning, :message => "optional parameter listed before required parameter", :linenumber => 2
      should_not have_problem :kind => :error
    }
  end

  describe 'foo::bar in foo/manifests/bar.pp' do
    let(:code) { "class foo::bar { }" }
    let(:path) { '/etc/puppet/modules/foo/manifests/bar.pp' }

    its(:problems) { should be_empty }
  end

  describe 'foo::bar::baz in foo/manifests/bar/baz.pp' do
    let(:code) { 'define foo::bar::baz() { }' }
    let(:path) { '/etc/puppet/modules/foo/manifests/bar/baz.pp' }

    its(:problems) { should be_empty }
  end

  describe 'foo in foo/manifests/init.pp' do
    let(:code) { 'class foo { }' }
    let(:path) { '/etc/puppet/modules/foo/manifests/init.pp' }

    its(:problems) { should be_empty }
  end

  describe 'foo::bar in foo/manifests/init.pp' do
    let(:code) { 'class foo::bar { }' }
    let(:path) { '/etc/puppet/modules/foo/manifests/init.pp' }

    its(:problems) {
      should only_have_problem :kind => :error, :message => "foo::bar not in autoload module layout", :linenumber => 1
    }
  end
end
