require 'spec_helper'

describe 'selector_inside_resource' do
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
end
