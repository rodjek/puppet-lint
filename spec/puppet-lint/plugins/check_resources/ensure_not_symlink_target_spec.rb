require 'spec_helper'

describe 'ensure_not_symlink_target' do
  describe 'file resource creating a symlink with seperate target attr' do
    let(:code) { "
      file { 'foo':
        ensure => link,
        target => '/foo/bar',
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'file resource creating a symlink with target specified in ensure' do
    let(:code) { "
      file { 'foo':
        ensure => '/foo/bar',
      }"
    }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "symlink target specified in ensure attr", :linenumber => 3
    }
  end
end
