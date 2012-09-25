require 'spec_helper'

describe 'arrow_alignment' do
  describe 'selectors inside a resource' do
    let(:code) { "
      file { 'foo':
        ensure  => $ensure,
        require => $ensure ? {
          present => Class['tomcat::install'],
          absent  => undef;
        },
        foo     => bar,
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

  describe 'single resource with a misaligned =>' do
    let(:code) { "
      file { '/tmp/foo':
        foo => 1,
        bar => 2,
        gronk => 3,
        baz  => 4,
        meh => 5,
      }"
    }

    its(:problems) do
      should have_problem({
        :kind       => :warning,
        :message    => 'indentation of => is not properly aligned',
        :linenumber => 5,
        :column     => 15,
      })
      should have_problem({
        :kind       => :warning,
        :message    => 'indentation of => is not properly aligned',
        :linenumber => 6,
        :column     => 14,
      })
    end
  end

  describe 'complex resource with a misaligned =>' do
    let(:code) { "
      file { '/tmp/foo':
        foo => 1,
        bar  => $baz ? {
          gronk => 2,
          meh => 3,
        },
        meep => 4,
        bah => 5,
      }"
    }

    its(:problems) do
      should have_problem({
        :kind       => :warning,
        :message    => 'indentation of => is not properly aligned',
        :linenumber => 4,
        :column     => 14,
      })
      should have_problem({
        :kind       => :warning,
        :message    => 'indentation of => is not properly aligned',
        :linenumber => 6,
        :column     => 15,
      })
      should have_problem({
        :kind       => :warning,
        :message    => 'indentation of => is not properly aligned',
        :linenumber => 8,
        :column     => 14,
      })
    end
  end

  describe 'multi-resource with a misaligned =>' do
    let(:code) { "
      file {
        '/tmp/foo': ;
        '/tmp/bar':
          foo => 'bar';
        '/tmp/baz':
          gronk => 'bah',
          meh => 'no'
      }"
    }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'indentation of => is not properly aligned',
        :linenumber => 8,
        :column     => 15,
      })
    end
  end

  describe 'multiple single line resources' do
    let(:code) { "
      file { 'foo': ensure => file }
      package { 'bar': ensure => present }"
    }

    its(:problems) { should be_empty }
  end

  describe 'resource with unaligned => in commented line' do
    let(:code) { "
      file { 'foo':
        ensure => directory,
        # purge => true,
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'single line resource spread out on multiple lines' do
    let(:code) {"
      file {
        'foo': ensure => present,
      }"
    }

    its(:problems) { should == [] }
  end
end
