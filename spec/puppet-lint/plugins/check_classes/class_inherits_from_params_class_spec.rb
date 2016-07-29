require 'spec_helper'

describe 'class_inherits_from_params_class' do
  let(:msg) { 'class inheriting from params class' }

  context 'parameterised class that inherits from a params class' do
    let(:code) { "
      # commented
      class foo($bar = $name) inherits foo::params { }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(40)
    end
  end

  context 'class without parameters' do
    let(:code) {"
      class myclass {

        if ( $::lsbdistcodename == 'squeeze' ) {
          #TODO
        }
      }
    "}

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
