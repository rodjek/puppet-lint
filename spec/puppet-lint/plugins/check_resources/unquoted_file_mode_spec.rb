require 'spec_helper'

describe 'unquoted_file_mode' do
  describe '4 digit unquoted file mode' do
    let(:code) { "file { 'foo': mode => 0777 }" }

    its(:problems) do
      should only_have_problem(
        :kind       => :warning,
        :message    => "unquoted file mode",
        :linenumber => 1,
        :column     => 23,
      )
    end
  end

  describe '4 digit unquoted file mode w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { 'foo': mode => 0777 }" }

    its(:problems) do
      should only_have_problem(
        :kind       => :fixed,
        :message    => "unquoted file mode",
        :linenumber => 1,
        :column     => 23,
      )
    end
    its(:manifest) { should == "file { 'foo': mode => '0777' }" }
  end
end
