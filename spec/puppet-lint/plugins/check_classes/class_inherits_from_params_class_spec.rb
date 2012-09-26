require 'spec_helper'

describe 'class_inherits_from_params_class' do
  describe 'parameterised class that inherits from a params class' do
    let(:code) { "
      # commented
      class foo($bar = $name) inherits foo::params { }"
    }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "class inheriting from params class",
        :linenumber => 3,
        :column     => 40,
      })
      should_not have_problem :kind => :error
    }
  end

  describe 'class without parameters' do
    let(:code) {"
      class myclass {

        if ( $::lsbdistcodename == 'squeeze' ) {
          #TODO
        }
      }
    "}

    its(:problems) { should == [] }
  end
end
