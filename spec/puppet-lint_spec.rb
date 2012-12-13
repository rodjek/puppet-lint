require 'spec_helper'

describe PuppetLint do
  subject { PuppetLint.new }

  it 'should accept manifests as a string' do
    subject.code = "class foo { }"
    subject.data.should_not be_nil
  end

  describe '#new' do
    it 'should not be quiet' do
      # ensure backward compatibility
      subject.quiet?.should be_false
    end

    it 'should have problems array' do
      subject.problems.should be_a_kind_of(Array)
    end

    it 'problems should be empty' do
      subject.problems.should be_empty
    end
  end

end
