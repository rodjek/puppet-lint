require 'spec_helper'

describe 'inherits_across_namespaces' do
  describe 'class inheriting from its namespace' do
    let(:code) { "class foo::bar inherits foo { }" }

    its(:problems) { should be_empty }
  end

  describe 'class inheriting from another namespace' do
    let(:code) { "class foo::bar inherits baz { }" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "class inherits across namespaces",
        :linenumber => 1,
        :column     => 25,
      })
      should_not have_problem :kind => :error
    }
  end
end
