require 'spec_helper'

describe 'inherits_across_namespaces' do
  describe 'class inheriting from parent in same module namespace' do
    let(:code) { "class foo::bar inherits foo { }" }

    its(:problems) { should be_empty }
  end

  describe 'class inheriting from sister in same module namespace' do
    let(:code) { "class foo::bar inherits foo::baz { }" }

    its(:problems) { should be_empty }
  end

  describe 'class inheriting from another module namespace' do
    let(:code) { "class foo::bar inherits baz { }" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "class inherits across module namespaces",
        :linenumber => 1,
        :column     => 25,
      })
      should_not have_problem :kind => :error
    }
  end
end
