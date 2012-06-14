require 'spec_helper'

describe PuppetLint::Plugins::CheckStrings do
  subject do
    klass = described_class.new
    klass.run(defined?(fullpath).nil? ? {:fullpath => ''} : {:fullpath => fullpath}, code)
    klass
  end

  describe 'double quoted string containing a variable insinde single quotes' do
    let(:code) { "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }" }

    its(:problems) { should be_empty }
  end

  describe 'multiple strings in a line' do
    let(:code) { "\"aoeu\" '${foo}'" }

    its(:problems) {
      should have_problem :kind => :warning, :message => 'double quoted string containing no variables', :linenumber => '1'
      should have_problem :kind => :error, :message => 'single quoted string containing a variable found', :linenumber => '1'
    }
  end

  describe 'string containing only a variable' do
    let(:code) { '"${foo}"' }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "string containing only a variable", :linenumber => '1'
    }
  end

  describe 'variable not enclosed in {}' do
    let(:code) { '" $gronk"' }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "variable not enclosed in {}", :linenumber => '1'
    }

  end

  describe 'variable not enclosed in {} after many tokens' do
    let(:code) { ("'groovy'\n" * 20) + '" $gronk"' }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "variable not enclosed in {}", :linenumber => '21'
    }

  end


  describe 'double quoted string nested in a single quoted string' do
    let(:code) { "'grep \"status=sent\" /var/log/mail.log'" }

    its(:problems) { should be_empty }
  end

  describe 'double quoted string after a comment' do
    let(:code) { "service { 'foo': } # \"bar\"" }

    its(:problems) { should be_empty }
  end

  describe 'double quoted string containing newline but no variables' do
    let(:code) { '"foo\n"' }

    its(:problems) { should be_empty }
  end

  describe 'quoted false' do
    let(:code) { "class { 'foo': boolFlag => 'false' }" }

    its(:problems) { should only_have_problem :kind => :warning, :message => "quoted boolean value found", :linenumber => 1 }
  end

  describe 'quoted true' do
    let(:code) { "class { 'foo': boolFlag => 'true' }" }

    its(:problems) { should only_have_problem :kind => :warning, :message => "quoted boolean value found", :linenumber => 1 }
  end

  describe 'double quoted true' do
    let(:code) { "class { 'foo': boolFlag => \"true\" }" }

    its(:problems) {
      should have_problem :kind => :warning, :message => "quoted boolean value found", :linenumber => 1

      should have_problem :kind => :warning, :message => 'double quoted string containing no variables', :linenumber => '1'
    }
  end

  describe 'double quoted false' do
    let(:code) { "class { 'foo': boolFlag => \"false\" }" }

    its(:problems) {
      should have_problem :kind => :warning, :message => "quoted boolean value found", :linenumber => 1

      should have_problem :kind => :warning, :message => 'double quoted string containing no variables', :linenumber => '1'
    }
  end
end
