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
  describe 'bug #145: resource with a hash and no duplicate parameters' do
    let (:code) { "
      class {'fooname':
        hashes => [
          { foo => 'bar01',},
          { foo => 'bar02', },
        ],
      }"
    }
    its (:problems) {
      should be_empty
    }
  end

  describe 'bug #145: resource with a hash and duplicate parameters in subhash' do
    let (:code) { "
      class {'fooname':
        hashes => [
          { foo => 'bar01',
            foo => 'bar02', },
        ],
      }"
    }
    its (:problems) {
      should only_have_problem({
        :kind       => :error,
        :message    => 'duplicate parameter found in resource',
        :linenumber => 5,
        :column     => 13,
      })
    }
  end

  describe 'bug #145: resource with a hash and duplicate parameters in parent type' do
    let (:code) { "
      class {'fooname':
        hashes    => [
          { foo     => 'bar01', },
          { foo     => 'bar02', },
        ],
        something => { hash => 'mini', },
        hashes    => 'dupe',
      }"
    }
    its (:problems) {
      should only_have_problem({
        :kind       => :error,
        :message    => 'duplicate parameter found in resource',
        :linenumber => 8,
        :column     => 9,
      })
    }
  end
  describe 'bug #145: more hash tests and no duplicate parameters' do
    let (:code) { "
      class test {
        $foo = { param => 'value', }
        $bar = { param => 'bar', }
      }"
    }
    its (:problems) {
      should be_empty
    }

  end
end
