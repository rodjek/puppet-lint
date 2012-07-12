require 'spec_helper'

describe PuppetLint::Plugins::CheckResources do
  subject do
    klass = described_class.new
    klass.run(defined?(fullpath).nil? ? {:fullpath => ''} : {:fullpath => fullpath}, code)
    klass
  end

  describe '3 digit file mode' do
    let(:code) { "file { 'foo': mode => '777' }" }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "mode should be represented as a 4 digit octal value or symbolic mode", :linenumber => 1
    }
  end

  describe '4 digit file mode' do
    let(:code) { "file { 'foo': mode => '0777' }" }

    its(:problems) { should be_empty }
  end

  describe '4 digit unquoted file mode' do
    let(:code) { "file { 'foo': mode => 0777 }" }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "unquoted file mode"
    }
  end

  describe 'file mode as a variable' do
    let(:code) { "file { 'foo': mode => $file_mode }" }

    its(:problems) { should be_empty }
  end

  describe 'symbolic file mode' do
    let(:code) { "file { 'foo': mode => 'u=rw,og=r' }" }

    its(:problems) { should be_empty }
  end

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

  describe 'quoted resource title on single line resource' do
    let(:code) { "file { 'foo': }" }

    its(:problems) { should be_empty }
  end

  describe 'unquoted resource title on single line resource' do
    let(:code) { "file { foo: }" }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "unquoted resource title", :linenumber => 1
    }
  end

  describe 'quoted resource title on multi line resource' do
    let(:code) { "
      file { 'foo':
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'unquoted resource title on multi line resource' do
    let(:code) { "
      file { foo:
      }"
    }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "unquoted resource title", :linenumber => 2
    }
  end

  describe 'condensed resources with quoted titles' do
    let(:code) { "
      file {
        'foo': ;
        'bar': ;
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'condensed resources with an unquoted title' do
    let(:code) { "
      file {
        'foo': ;
        bar: ;
      }"
    }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "unquoted resource title", :linenumber => 4
    }
  end

  describe 'single line resource with an array of titles (all quoted)' do
    let(:code) { "file { ['foo', 'bar']: }" }

    its(:problems) { should be_empty }
  end

  describe 'resource inside a case statement' do
    let(:code) { "
      case $ensure {
        'absent': {
          file { \"some_file_${name}\":
            ensure => absent,
          }
        }
      }"
    }

    its(:problems) { should == [] }
  end

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

  # This should really be a lexer test, but I haven't had time to write that
  # test suite yet.
  describe 'issue #116' do
    let(:code) { "
      $config_file_init = $::operatingsystem ? {
        /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/foo',
        default                   => '/etc/sysconfig/foo',
      }"
    }

    its(:problems) { should == [] }
  end
end
