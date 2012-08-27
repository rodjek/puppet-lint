require 'spec_helper'

describe 'documentation' do
  describe 'undocumented class' do
    let(:code) { "class test {}" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'class not documented',
        :linenumber => 1,
        :column     => 1,
      })
    end
  end

  describe 'documented class' do
    let(:code) { "
      # foo
      class test {}
    "}

    its(:problems) { should == [] }
  end

  describe 'undocumented defined type' do
    let(:code) { "define test {}" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'defined type not documented',
        :linenumber => 1,
        :column     => 1,
      })
    end
  end

  describe 'documented defined type' do
    let(:code) { "
      # foo
      define test {}
    "}

    its(:problems) { should == [] }
  end
end
