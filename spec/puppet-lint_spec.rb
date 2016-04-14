require 'spec_helper'

describe PuppetLint do
  subject { PuppetLint.new }

  it 'should accept manifests as a string' do
    subject.code = "class foo { }"
    expect(subject.code).to_not be_nil
  end

  it 'should have support for % with a hash' do
    string = 'replace %{hash}' % {:hash => 'replaced'}
    expect(string).to match('replace replaced')
  end

  it 'should not break regular % support' do
    string = 'replace %s %s' % ['get','replaced']
    expect(string).to match('replace get replaced')
  end

  it 'should return empty manifest when empty one given as the input' do
    subject.code = ''
    subject.run
    expect(subject.manifest).to eq ''
  end
end
