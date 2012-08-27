require 'spec_helper'

describe 'duplicate_params' do
  describe 'resource with duplicate parameters' do
    let(:code) { "
      file { '/tmp/foo':
        ensure => present,
        foo => bar,
        baz => gronk,
        foo => meh,
      }"
    }

    its(:problems) {
      should only_have_problem({
        :kind       => :error,
        :message    => 'duplicate parameter found in resource',
        :linenumber => 6,
        :column     => 9,
      })
    }
  end
end
