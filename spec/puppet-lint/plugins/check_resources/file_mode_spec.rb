require 'spec_helper'

describe 'file_mode' do
  describe '3 digit file mode' do
    let(:code) { "file { 'foo': mode => '777' }" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => "mode should be represented as a 4 digit octal value or symbolic mode",
        :linenumber => 1,
        :column     => 23,
      })
    end
  end

  describe '3 digit file mode w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { 'foo': mode => '777' }" }

    its(:manifest) { should == "file { 'foo': mode => '0777' }" }
    its(:problems) do
      should only_have_problem({
        :kind       => :fixed,
        :message    => 'mode should be represented as a 4 digit octal value or symbolic mode',
        :linenumber => 1,
      })
    end
  end

  describe '4 digit file mode' do
    let(:code) { "file { 'foo': mode => '0777' }" }

    its(:problems) { should be_empty }
  end

  describe '4 digit file mode w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { 'foo': mode => '0777' }" }

    its(:problems) { should be_empty }
    its(:manifest) { should == "file { 'foo': mode => '0777' }" }
  end

  describe 'file mode as a variable' do
    let(:code) { "file { 'foo': mode => $file_mode }" }

    its(:problems) { should be_empty }
  end

  describe 'file mode as a variable w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { 'foo': mode => $file_mode }" }

    its(:problems) { should be_empty }
    its(:manifest) { should == "file { 'foo': mode => $file_mode }" }
  end

  describe 'symbolic file mode' do
    let(:code) { "file { 'foo': mode => 'u=rw,og=r' }" }

    its(:problems) { should be_empty }
  end

  describe 'symbolic file mode w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { 'foo': mode => 'u=rw,og=r' }" }

    its(:problems) { should be_empty }
    its(:manifest) { should == "file { 'foo': mode => 'u=rw,og=r' }" }
  end

  describe 'file mode undef unquoted' do
    let(:code) { "file { 'foo': mode => undef }" }

    its(:problems) { should be_empty }
  end

  describe 'file mode undef unquoted w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { 'foo': mode => undef }" }

    its(:problems) { should be_empty }
    its(:manifest) { should == "file { 'foo': mode => undef }" }
  end

  describe 'file mode undef quoted' do
    let(:code) { "file { 'foo': mode => 'undef' }" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => "mode should be represented as a 4 digit octal value or symbolic mode",
        :linenumber => 1,
        :column     => 23,
      })
    end
  end

  describe 'file mode undef quoted' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { 'foo': mode => 'undef' }" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => "mode should be represented as a 4 digit octal value or symbolic mode",
        :linenumber => 1,
        :column     => 23,
      })
    end
    its(:manifest) { should == "file { 'foo': mode => 'undef' }" }
  end
end
