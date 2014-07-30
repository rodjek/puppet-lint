require 'spec_helper'

describe PuppetLint::Lexer::Token do
  subject do
    PuppetLint::Lexer::Token.new(:NAME, 'foo', 1, 2)
  end

  it { is_expected.to respond_to(:type) }
  it { is_expected.to respond_to(:value) }
  it { is_expected.to respond_to(:line) }
  it { is_expected.to respond_to(:column) }

  its(:type) { is_expected.to eq(:NAME) }
  its(:value) { is_expected.to eq('foo') }
  its(:line) { is_expected.to eq(1) }
  its(:column) { is_expected.to eq(2) }
  its(:inspect) { is_expected.to eq("<Token :NAME (foo) @1:2>") }
end
