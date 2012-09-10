require 'spec_helper'

describe 'class_parameter_defaults' do
  describe 'parameterised class with a default value' do
    let(:code) { "class foo($bar, $baz='gronk') { }" }

    its(:problems) {
      should only_have_problem({
        :kind => :warning,
        :message => 'parameterised class parameter without a default value',
        :linenumber => 1,
        :column     => 11,
      })
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

  describe 'parameterised class with a function value' do
    let(:code) { "class foo($bar = baz($gronk)) { }" }

    its(:problems) { should == [] }
  end
end
