require 'spec_helper'

describe PuppetLint::Plugins::CheckWhitespace do
  subject do
    klass = described_class.new
    klass.run(defined?(path).nil? ? '' : path, code)
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

    its(:problems) { should be_empty }
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

    its(:problems) { should be_empty }
  end

  describe 'file resource with a source line > 80c' do
    let(:code) { "
      file {
        source  => 'puppet:///modules/certificates/etc/ssl/private/wildcard.example.com.crt',
      }"
    }

    its(:problems) { should be_empty }
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

    its(:problems) { should be_empty }
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

    its(:problems) { should be_empty }
  end

  describe 'issue #37' do
    let(:code) { "
      class { 'lvs::base':
        virtualeservers => {
          '192.168.2.13' => {
            vport           => '11025',
            service         => 'smtp',
            scheduler       => 'wlc',
            protocol        => 'tcp',
            checktype       => 'external',
            checkcommand    => '/path/to/checkscript',
            real_servers    => {
              'server01' => {
                real_server => '192.168.2.14',
                real_port   => '25',
                forwarding  => 'masq',
              },
              'server02' => {
                real_server => '192.168.2.15',
                real_port   => '25',
                forwarding  => 'masq',
              }
            }
          }
        }
      }"
    }

    its(:problems) { should be_empty }
  end
end
