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
end
