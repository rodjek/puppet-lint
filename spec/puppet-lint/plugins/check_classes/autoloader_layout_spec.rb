require 'spec_helper'

describe 'autoloader_layout' do
  describe 'foo::bar in foo/manifests/bar.pp' do
    let(:code) { "class foo::bar { }" }
    let(:fullpath) { '/etc/puppet/modules/foo/manifests/bar.pp' }

    its(:problems) { should be_empty }
  end

  describe 'foo::bar::baz in foo/manifests/bar/baz.pp' do
    let(:code) { 'define foo::bar::baz() { }' }
    let(:fullpath) { '/etc/puppet/modules/foo/manifests/bar/baz.pp' }

    its(:problems) { should be_empty }
  end

  describe 'foo in foo/manifests/init.pp' do
    let(:code) { 'class foo { }' }
    let(:fullpath) { '/etc/puppet/modules/foo/manifests/init.pp' }

    its(:problems) { should be_empty }
  end

  describe 'foo::bar in foo/manifests/init.pp' do
    let(:code) { 'class foo::bar { }' }
    let(:fullpath) { '/etc/puppet/modules/foo/manifests/init.pp' }

    its(:problems) {
      should only_have_problem({
        :kind       => :error,
        :message    => "foo::bar not in autoload module layout",
        :linenumber => 1,
        :column     => 7,
      })
    }
  end

  describe 'foo included in bar/manifests/init.pp' do
    let(:code) { "
      class bar {
        class {'foo':
          someparam => 'somevalue',
        }
      }
      "
    }
    let(:fullpath) { '/etc/puppet/modules/bar/manifests/init.pp' }
    its(:problems) { should be_empty }
  end
end
