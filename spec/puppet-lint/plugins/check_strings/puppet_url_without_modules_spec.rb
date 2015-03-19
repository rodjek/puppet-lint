require 'spec_helper'

describe 'puppet_url_without_modules' do
  let(:msg) { 'puppet:// URL without modules/ found' }

  context 'puppet:// url with modules' do
    let(:code) { "'puppet:///modules/foo'" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'puppet:// url without modules' do
    let(:code) { "'puppet:///foo'" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(1)
    end
  end

  context 'puppet:// url with user defined urls' do
    before(:all) do
      PuppetLint.configuration.file_server_conf = 'spec/fixtures/test/manifests/fileserver.conf'
    end

    after(:all) do
      PuppetLint.configuration.file_server_conf = nil
    end

    let(:code) { "'puppet:///bigfiles/foo'" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
