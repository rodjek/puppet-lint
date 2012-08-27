require 'spec_helper'

describe 'names_containing_dash' do
  describe 'module named foo-bar' do
    let(:code) { 'class foo-bar { }' }
    let(:fullpath) { '/etc/puppet/modules/foo-bar/manifests/init.pp' }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'class name containing a dash',
        :linenumber => 1,
        :column     => 7,
      })
    end
  end

  describe 'define named foo-bar' do
    let(:code) { 'define foo::foo-bar { }' }
    let(:fullpath) { '/etc/puppet/modules/foo/manifests/foo-bar.pp' }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'defined type name containing a dash',
        :linenumber => 1,
        :column     => 8,
      })
    end
  end

  describe 'class named bar-foo' do
    let(:code) { 'class foo::bar-foo { }' }
    let(:fullpath) { '/etc/puppet/modules/foo/manifests/bar-foo.pp' }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'class name containing a dash',
        :linenumber => 1,
        :column     => 7,
      })
    end
  end
end
