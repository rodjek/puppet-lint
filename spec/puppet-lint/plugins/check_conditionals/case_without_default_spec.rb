require 'spec_helper'

describe 'case_without_default' do
  let(:msg) { 'case statement without a default case' }

  context 'case statement with a default case' do
    let(:code) { "
      case $foo {
        bar: { }
        default: { }
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'case statement without a default case' do
    let(:code) { "
      case $foo {
        bar: { }
        baz: { }
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(7)
    end
  end

  context 'issue-117' do
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

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
