require 'spec_helper'

describe PuppetLint::Plugins::CheckConditionals do
  subject do
    klass = described_class.new
    klass.run(defined?(path).nil? ? '' : path, code)
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

    its(:warnings) { should include "selector inside resource block on line 3" }
    its(:errors) { should be_empty }
  end

  describe 'resource with a variable as a attr value' do
    let(:code) { "
      file { 'foo',
        ensure => $bar,
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'case statement with a default case' do
    let(:code) { "
      case $foo {
        bar: { }
        default: { }
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'case statement without a default case' do
    let(:code) { "
      case $foo {
        bar: { }
        baz: { }
      }"
    }

    its(:warnings) { should include "case statement without a default case on line 2" }
    its(:errors) { should be_empty }
  end
end
