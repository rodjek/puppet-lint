require 'spec_helper'

describe PuppetLint do
  subject { PuppetLint.new }

  it 'should accept manifests as a string' do
    subject.code = 'class foo { }'
    expect(subject.code).to_not be_nil
  end

  it 'should return empty manifest when empty one given as the input' do
    subject.code = ''
    subject.run
    expect(subject.manifest).to eq('')
  end
end
