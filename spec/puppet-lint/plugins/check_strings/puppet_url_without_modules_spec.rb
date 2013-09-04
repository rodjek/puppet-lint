require 'spec_helper'

describe 'puppet_url_without_modules' do
  describe 'puppet:// url with modules' do
    let(:code) { "'puppet:///modules/foo'" }

    its(:problems) { should be_empty }
  end

  describe 'puppet:// url without modules' do
    let(:code) { "'puppet:///foo'" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => 'puppet:// URL without modules/ found',
        :linenumber => 1,
        :column     => 1,
      })
    end
  end
end
