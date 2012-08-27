require 'spec_helper'

describe 'parameter_order' do
  describe 'define with attrs in order' do
    let(:code) { "define foo($bar, $baz='gronk') { }" }

    its(:problems) { should be_empty }
  end

  describe 'define with parameter that calls a function' do
    let(:code) { "define foo($bar=extlookup($name)) {}" }

    its(:problems) { should == [] }
  end

  describe 'define with attrs out of order' do
    let(:code) { "define foo($bar='baz', $gronk) { }" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "optional parameter listed before required parameter",
        :linenumber => 1,
        :column     => 24,
      })
      should_not have_problem :kind => :error
    }
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
      should have_problem({
        :kind       => :warning,
        :message    => "optional parameter listed before required parameter",
        :linenumber => 2,
        :column     => 32,
      })
      should_not have_problem :kind => :error
    }
  end

  describe 'issue-101' do
    let(:code) { "
      define b (
        $foo,
        $bar='',
        $baz={}
      ) { }
    " }

    its(:problems) { should == [] }
  end
end
