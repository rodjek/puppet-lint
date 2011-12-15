require 'spec_helper'

describe PuppetLint::Plugins::CheckStrings do
  subject do
    klass = described_class.new
    klass.test(code)
    klass
  end

  describe 'double quoted string containing a variable insinde single quotes' do
    let(:code) { "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'multiple strings in a line' do
    let(:code) { "\"aoeu\" '${foo}'" }

    its(:warnings) { should include "double quoted string containing no variables on line 1" }
    its(:errors) { should include "single quoted string containing a variable found on line 1" }
  end

  describe 'string containing only a variable' do
    let(:code) { '"${foo}"' }

    its(:warnings) { should include "string containing only a variable on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'variable not enclosed in {}' do
    let(:code) { '" $gronk"' }

    its(:warnings) { should include "variable not enclosed in {} on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'variable containing a dash' do
    let(:code) { '" $foo-bar"' }

    its(:warnings) { should include "variable contains a dash on line 1" }
    its(:errors) { should be_empty }
  end

  describe 'double quoted string nested in a single quoted string' do
    let(:code) { "'grep \"status=sent\" /var/log/mail.log'" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'double quoted string after a comment' do
    let(:code) { "service { 'foo': } # \"bar\"" }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end

  describe 'double quoted string containing newline but no variables' do
    let(:code) { '"foo\n"' }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end
end
