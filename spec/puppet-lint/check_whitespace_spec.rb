require 'spec_helper'

describe PuppetLint::Plugins::CheckWhitespace do
  subject do
    klass = described_class.new
    klass.test(code)
    klass
  end

  describe 'selectors inside a resource' do
    let(:code) { "
      file { 'foo':
        ensure  => $ensure,
        require => $ensure ? {
          present => Class['tomcat::install'],
          absent  => undef,
        },
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'selectors in the middle of a resource' do
    let(:code) { "
      file { 'foo':
        ensure => $ensure ? {
          present => directory,
          absent  => undef,
        },
        owner  => 'tomcat6',
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'file resource with a source line > 80c' do
    let(:code) { "
      file {
        source  => 'puppet:///modules/certificates/etc/ssl/private/wildcard.example.com.crt',
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'selector inside a resource' do
    let(:code) { "
    ensure => $ensure ? {
      present => directory,
      absent  => undef,
    },
    owner  => 'foo4',
    group  => 'foo4',
    mode   => '0755'," }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'selector inside a hash inside a resource' do
    let(:code) { "
    server => {
      ensure => ensure => $ensure ? {
        present => directory,
        absent  => undef,
      },
      ip     => '192.168.1.1'
    },
    owner  => 'foo4',
    group  => 'foo4',
    mode   => '0755'," }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end
end
