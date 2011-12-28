require 'spec_helper'

describe PuppetLint::Plugins::CheckResources do
  subject do
    klass = described_class.new
    klass.run(defined?(path).nil? ? '' : path, code)
    klass
  end

  describe '3 digit file mode' do
    let(:code) { "file { 'foo': mode => 777 }" }

    its(:warnings) { should include "mode should be represented as a 4 digit octal value on line 1" }
    its(:errors) { should be_empty }
  end

  describe '4 digit file mode' do
    let(:code) { "file { 'foo': mode => '0777' }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'file mode as a variable' do
    let(:code) { "file { 'foo': mode => $file_mode }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'ensure as only attr in a single line resource' do
    let(:code) { "file { 'foo': ensure => present }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'ensure as only attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        ensure => present,
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'ensure as second attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        mode   => '0000',
        ensure => present,
      }"
    }

    its(:warnings) { should include "ensure found on line 4 but it's not the first attribute" }
    its(:errors) { should be_empty }
  end

  describe 'ensure as first attr in a multi line resource' do
    let(:code) { "
      file { 'foo':
        ensure => present,
        mode   => '0000',
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'quoted resource title on single line resource' do
    let(:code) { "file { 'foo': }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'unquoted resource title on single line resource' do
    let(:code) { "file { foo: }" }

    its(:warnings) { should include "unquoted resource title on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'quoted resource title on multi line resource' do
    let(:code) { "
      file { 'foo':
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'unquoted resource title on multi line resource' do
    let(:code) { "
      file { foo:
      }"
    }

    its(:warnings) { should include "unquoted resource title on line 2" }
    its(:errors) { should be_empty }
  end

  describe 'condensed resources with quoted titles' do
    let(:code) { "
      file {
        'foo': ;
        'bar': ;
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'condensed resources with an unquoted title' do
    let(:code) { "
      file {
        'foo': ;
        bar: ;
      }"
    }

    its(:warnings) { should include "unquoted resource title on line 4" }
    its(:errors) { should be_empty }
  end

  describe 'single line resource with an array of titles (all quoted)' do
    let(:code) { "file { ['foo', 'bar']: }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
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

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'file resource creating a symlink with seperate target attr' do
    let(:code) { "
      file { 'foo':
        ensure => link,
        target => '/foo/bar',
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'file resource creating a symlink with target specified in ensure' do
    let(:code) { "
      file { 'foo':
        ensure => '/foo/bar',
      }"
    }

    its(:warnings) { should include "symlink target specified in ensure attr on line 3" }
    its(:errors) { should be_empty }
  end
end
