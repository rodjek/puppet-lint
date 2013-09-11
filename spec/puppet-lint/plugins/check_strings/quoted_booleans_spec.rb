require 'spec_helper'

describe 'quoted_booleans' do
  describe 'quoted false' do
    let(:code) { "class { 'foo': boolFlag => 'false' }" }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
  end

  describe 'quoted true' do
    let(:code) { "class { 'foo': boolFlag => 'true' }" }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
  end

  describe 'double quoted true' do
    let(:code) { "class { 'foo': boolFlag => \"true\" }" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
  end

  describe 'double quoted false' do
    let(:code) { "class { 'foo': boolFlag => \"false\" }" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
  end

  describe 'quoted false w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "class { 'foo': boolFlag => 'false' }" }

    its(:problems) {
      should only_have_problem({
        :kind       => :fixed,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
    its(:manifest) { should == "class { 'foo': boolFlag => false }" }
  end

  describe 'quoted true w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "class { 'foo': boolFlag => 'true' }" }

    its(:problems) {
      should only_have_problem({
        :kind       => :fixed,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
    its(:manifest) { should == "class { 'foo': boolFlag => true }" }
  end

  describe 'double quoted true w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "class { 'foo': boolFlag => \"true\" }" }

    its(:problems) {
      should have_problem({
        :kind       => :fixed,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
    its(:manifest) { should == "class { 'foo': boolFlag => true }" }
  end

  describe 'double quoted false w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "class { 'foo': boolFlag => \"false\" }" }

    its(:problems) {
      should have_problem({
        :kind       => :fixed,
        :message    => 'quoted boolean value found',
        :linenumber => 1,
        :column     => 28,
      })
    }
    its(:manifest) { should == "class { 'foo': boolFlag => false }" }
  end
end
