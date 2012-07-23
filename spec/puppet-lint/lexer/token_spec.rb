require 'spec_helper'

describe PuppetLint::Lexer::Token do
  subject do
    PuppetLint::Lexer::Token.new(:NAME, 'foo', 1, 2)
  end

  it { should respond_to(:type) }
  it { should respond_to(:value) }
  it { should respond_to(:line) }
  it { should respond_to(:column) }

  its(:type) { should == :NAME }
  its(:value) { should == 'foo' }
  its(:line) { should == 1 }
  its(:column) { should == 2 }
  its(:inspect) { should == "<Token :NAME (foo) @1:2>" }
end
