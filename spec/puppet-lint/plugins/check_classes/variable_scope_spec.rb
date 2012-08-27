require 'spec_helper'

describe 'variable_scope' do
  describe 'class with no variables declared accessing top scope' do
    let(:code) { "
      class foo {
        $bar = $baz
      }"
    }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "top-scope variable being used without an explicit namespace",
        :linenumber => 3,
        :column     => 16,
      })
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
      class foo($bar='UNSET') {
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
      should have_problem({
        :kind       => :warning,
        :message    => "top-scope variable being used without an explicit namespace",
        :linenumber => 3,
        :column     => 16,
      })
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
end
