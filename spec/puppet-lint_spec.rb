require 'spec_helper'

describe PuppetLint do
  subject { PuppetLint.new }

  it 'should accept manifests as a string' do
    subject.code = "class foo { }"
    subject.data.should_not be_nil
  end
end
