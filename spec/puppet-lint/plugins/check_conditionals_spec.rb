require 'spec_helper'

describe PuppetLint::Plugins::CheckConditionals do
  subject do
    klass = described_class.new
    fileinfo = {}
    fileinfo[:fullpath] = defined?(fullpath).nil? ? '' : fullpath
    klass.run(fileinfo, code)
    klass
  end

  describe 'resource with a selector' do
    let(:code) { "
      file { 'foo':
        ensure => $bar ? {
          true    => present,
          default => absent,
        },
      }"
    }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'selector inside resource block',
        :linenumber => 3,
        :column     => 16,
      })
    end
  end

  describe 'resource with a variable as a attr value' do
    let(:code) { "
      file { 'foo',
        ensure => $bar,
      }"
    }

    its(:problems) { should be_empty }
  end

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
end
