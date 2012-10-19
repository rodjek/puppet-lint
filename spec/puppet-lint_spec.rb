require 'spec_helper'

describe PuppetLint do
  subject { PuppetLint.new }

  it 'should accept manifests as a string' do
    subject.code = "class foo { }"
    subject.data.should_not be_nil
  end

  it 'should have support for % with a hash' do
    string = 'replace %{hash}' % {:hash => 'replaced'}
    string.should match 'replace replaced'
  end

  it 'should not break regular % support' do
    string = 'replace %s %s' % ['get','replaced']
    string.should match 'replace get replaced'
  end
end
