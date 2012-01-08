require 'spec_helper'

describe PuppetLint::Plugins::CheckResources do
  subject do
    klass = described_class.new
    klass.run(defined?(path).nil? ? '' : path, code)
    klass
  end

  describe '3 digit file mode' do
    let(:code) { "file { 'foo': mode => 777 }" }

    its(:problems) {
      should have_problem :kind => :warning, :message => "mode should be represented as a 4 digit octal value", :linenumber => 1
      should_not have_problem :kind => :error
    }
  end

  describe '4 digit file mode' do
    let(:code) { "file { 'foo': mode => '0777' }" }

    its(:problems) { should be_empty }
  end

  describe 'file mode as a variable' do
    let(:code) { "file { 'foo': mode => $file_mode }" }

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
      should have_problem :kind => :warning, :message => "ensure found on line but it's not the first attribute", :linenumber => 4
      should_not have_problem :kind => :error
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
      should have_problem :kind => :warning, :message => "unquoted resource title", :linenumber => 1
      should_not have_problem :kind => :error
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
      should have_problem :kind => :warning, :message => "unquoted resource title", :linenumber => 2
      should_not have_problem :kind => :error
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
      should have_problem :kind => :warning, :message => "unquoted resource title", :linenumber => 4
      should_not have_problem :kind => :error
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

    its(:problems) { should be_empty }
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
      should have_problem :kind => :warning, :message => "symlink target specified in ensure attr", :linenumber => 3
      should_not have_problem :kind => :error
    }
  end
end
