require 'spec_helper'

describe 'ensure_first_param' do
  describe 'ensure as only attr in a single line resource' do
    let(:code) { "file { 'foo': ensure => present }" }

    its(:problems) { should be_empty }
  end

  describe 'ensure as only attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        ensure => present,
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'ensure as second attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        mode   => '0000',
        ensure => present,
      }"
    }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "ensure found on line but it's not the first attribute", :linenumber => 4
    }
  end

  describe 'ensure as first attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        ensure => present,
        mode   => '0000',
      }"
    }

    its(:problems) { should be_empty }
  end
end
