require 'spec_helper'

describe 'case_without_default' do
  describe 'case statement with a default case' do
    let(:code) { "
      case $foo {
        bar: { }
        default: { }
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'case statement without a default case' do
    let(:code) { "
      case $foo {
        bar: { }
        baz: { }
      }"
    }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'case statement without a default case',
        :linenumber => 2,
        :column     => 7,
      })
    end
  end

  describe 'issue-117' do
    let(:code) { "
      $mem = inline_template('<%
        mem,unit = scope.lookupvar(\'::memorysize\').split
        mem = mem.to_f
        # Normalize mem to bytes
        case unit
            when nil:  mem *= (1<<0)
            when \'kB\': mem *= (1<<10)
            when \'MB\': mem *= (1<<20)
            when \'GB\': mem *= (1<<30)
            when \'TB\': mem *= (1<<40)
        end
        %><%= mem.to_i %>')
    "}

    its(:problems) { should == [] }
  end
end
