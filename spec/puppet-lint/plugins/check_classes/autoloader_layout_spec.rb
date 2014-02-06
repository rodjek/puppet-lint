require 'spec_helper'

describe 'autoloader_layout' do
  context 'foo::bar in foo/manifests/bar.pp' do
    let(:code) { "class foo::bar { }" }
    let(:path) { 'foo/manifests/bar.pp' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'foo::bar::baz in foo/manifests/bar/baz.pp' do
    let(:code) { 'define foo::bar::baz() { }' }
    let(:path) { 'foo/manifests/bar/baz.pp' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'foo in foo/manifests/init.pp' do
    let(:code) { 'class foo { }' }
    let(:path) { 'foo/manifests/init.pp' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'foo::bar in foo/manifests/init.pp' do
    let(:code) { 'class foo::bar { }' }
    let(:path) { 'foo/manifests/init.pp' }
    let(:msg) { 'foo::bar not in autoload module layout' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(1).in_column(7)
    end
  end

  context 'foo included in bar/manifests/init.pp' do
    let(:code) { "
      class bar {
        class {'foo':
          someparam => 'somevalue',
        }
      }
      "
    }
    let(:path) { 'bar/manifests/init.pp' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'foo in puppet-foo/manifests/init.pp' do
    let(:code) { 'class foo { }' }
    let(:path) { 'puppet-foo/manifests/init.pp' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problems
    end
  end

  context 'foo in puppet-foo/manifests/bar.pp with relative option' do
    before do
      PuppetLint.configuration.relative = true
    end

    after do
      PuppetLint.configuration.relative = false
    end

    let(:code) { 'class foo { }' }
    let(:path) { 'puppet-foo/manifests/bar.pp' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problems
    end
  end

  context 'foo in puppet-foo/manifests/init.pp with relative option' do
    before do
      PuppetLint.configuration.relative = true
    end

    after do
      PuppetLint.configuration.relative = false
    end

    let(:code) { 'class foo { }' }
    let(:path) { 'puppet-foo/manifests/init.pp' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end


end
