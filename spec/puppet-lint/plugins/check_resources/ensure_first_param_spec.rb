require 'spec_helper'

describe 'ensure_first_param' do
  let(:msg) { "ensure found on line but it's not the first attribute" }

  context 'ensure as only attr in a single line resource' do
    let(:code) { "file { 'foo': ensure => present }" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'ensure as only attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        ensure => present,
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'ensure as second attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        mode   => '0000',
        ensure => present,
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(4).in_column(9)
    end
  end

  context 'ensure as first attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        ensure => present,
        mode   => '0000',
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'ensure as a hash key in classes does not need to be first' do
    let(:code) { "
      class thing {
          class {'thang':
              stuff => {
                  'stuffing' => {
                      ensure => 'present',
                      blah   => 'bleah',
                  }
              },
          }
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
