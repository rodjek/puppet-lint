require 'spec_helper'

describe PuppetLint::Data do
  subject(:data) { PuppetLint::Data }
  let(:lexer) { PuppetLint::Lexer.new }

  describe '.resource_indexes' do
    before(:each) do
      data.tokens = lexer.tokenise(manifest)
    end

    context 'when a namespaced class name contains a single colon' do
      let(:manifest) { 'class foo:bar { }' }

      it 'raises a SyntaxError' do
        expect {
          data.resource_indexes
        }.to raise_error(PuppetLint::SyntaxError) { |error|
          expect(error.token).to eq(data.tokens[3])
        }
      end
    end
  end

  describe '.insert' do
    let(:manifest) { '$x = $a' }
    let(:new_token) { PuppetLint::Lexer::Token.new(:PLUS, '+', 0, 0) }
    let(:original_tokens) { lexer.tokenise(manifest) }
    let(:tokens) { original_tokens.dup }
    before do
      data.tokens = tokens
      data.insert(2, new_token)
    end

    it 'adds token at the given index' do
      expect(data.tokens.map(&:to_manifest).join).to eq('$x += $a')
    end

    it 'sets the prev_token' do
      expect(new_token.prev_token).to eq(original_tokens[1])
    end

    it 'sets the prev_code_token' do
      expect(new_token.prev_code_token).to eq(original_tokens[0])
    end

    it 'sets the next_token' do
      expect(new_token.next_token).to eq(original_tokens[2])
    end

    it 'sets the next_code_token' do
      expect(new_token.next_code_token).to eq(original_tokens[2])
    end

    it 'updates the existing next_token' do
      expect(tokens[1].next_token).to eq(new_token)
    end

    it 'updates the existing next_code_token' do
      expect(tokens[0].next_code_token).to eq(new_token)
    end

    it 'updates the existing prev_token' do
      expect(tokens[3].prev_token).to eq(new_token)
    end

    it 'updates the existing prev_code_token' do
      expect(tokens[3].prev_code_token).to eq(new_token)
    end
  end

  describe '.delete' do
    let(:manifest) { '$x + = $a' }
    let(:token) { tokens[2] }
    let(:original_tokens) { lexer.tokenise(manifest) }
    let(:tokens) { original_tokens.dup }
    before do
      data.tokens = tokens
      data.delete(token)
    end

    it 'removes the token' do
      expect(data.tokens.map(&:to_manifest).join).to eq('$x  = $a')
    end

    it 'updates the existing next_token' do
      expect(tokens[1].next_token).to eq(original_tokens[3])
    end

    it 'updates the existing next_code_token' do
      expect(tokens[0].next_code_token).to eq(original_tokens[4])
    end

    it 'updates the existing prev_token' do
      expect(tokens[2].prev_token).to eq(original_tokens[1])
    end

    it 'updates the existing prev_code_token' do
      expect(tokens[3].prev_code_token).to eq(original_tokens[0])
    end
  end
end
