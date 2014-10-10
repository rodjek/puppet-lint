require 'spec_helper'

describe 'duplicate_params' do
  let(:msg) { 'duplicate parameter found in resource' }

  context 'resource with duplicate parameters' do
    let(:code) { "
      file { '/tmp/foo':
        ensure => present,
        foo => bar,
        baz => gronk,
        foo => meh,
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(6).in_column(9)
    end
  end

  context 'bug #145: resource with a hash and no duplicate parameters' do
    let(:code) { "
      class {'fooname':
        hashes => [
          { foo => 'bar01',},
          { foo => 'bar02', },
        ],
      }"
    }

    it 'should not detect any errors' do
      expect(problems).to have(0).problems
    end
  end

  context 'bug #145: resource with a hash and duplicate parameters in subhash' do
    let(:code) { "
      class {'fooname':
        hashes => [
          { foo => 'bar01',
            foo => 'bar02', },
        ],
      }"
    }

    it 'should only detect a single error' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(5).in_column(13)
    end
  end

  context 'bug #145: resource with a hash and duplicate parameters in parent type' do
    let(:code) { "
      class {'fooname':
        hashes    => [
          { foo     => 'bar01', },
          { foo     => 'bar02', },
        ],
        something => { hash => 'mini', },
        hashes    => 'dupe',
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(8).in_column(9)
    end
  end

  describe 'bug #145: more hash tests and no duplicate parameters' do
    let(:code) { "
      class test {
        $foo = { param => 'value', }
        $bar = { param => 'bar', }
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'colon as last token in file' do
    let(:code) { "}:" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
