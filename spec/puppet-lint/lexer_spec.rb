# encoding: utf-8

require 'spec_helper'

describe PuppetLint::Lexer do
  subject(:lexer) do
    described_class.new
  end

  context 'invalid code' do
    it 'borks' do
      expect { lexer.tokenise('^') }.to raise_error(PuppetLint::LexerError)
    end
  end

  context '#new_token' do
    it 'calculates the line number for an empty string' do
      token = lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(1)
    end

    it 'gets correct line number after double quoted multi line string' do
      lexer.new_token(:STRING, "test\ntest")
      token = lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'gets correct line number after a multi line comment' do
      lexer.new_token(:MLCOMMENT, "test\ntest", raw: "/*test\ntest*/")
      token = lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'calculates the line number for a multi line string' do
      lexer.new_token(:SSTRING, "test\ntest")
      token = lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'calculates line number for string that ends with newline' do
      lexer.new_token(:SSTRING, "test\n")
      token = lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'calculates the column number for an empty string' do
      token = lexer.new_token(:TEST, 'test')
      expect(token.column).to eq(1)
    end

    it 'calculates the column number for a single line string' do
      lexer.new_token(:SSTRING, 'this is a test')
      token = lexer.new_token(:TEST, 'test')
      expect(token.column).to eq(17)
    end

    it 'calculates the column number for a multi line string' do
      lexer.instance_variable_set('@line_no', 4)
      lexer.instance_variable_set('@column', 5)
      lexer.new_token(:SSTRING, "test\ntest")
      token = lexer.new_token(:TEST, 'test')
      expect(token.column).to eq(6)
    end
  end

  context '#process_string_segments' do
    subject(:tokens) { lexer.tokens }

    subject(:manifest) { lexer.tokens.map(&:to_manifest).join }

    before(:each) do
      lexer.process_string_segments(segments)
    end

    context 'an empty string segment' do
      let(:segments) do
        [
          [:STRING, ''],
        ]
      end

      it 'creates a :STRING token' do
        expect(tokens).to have(1).token
        expect(tokens[0]).to have_attributes(
          type: :STRING,
          value: '',
          line: 1,
          column: 1,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('""')
      end
    end

    context 'an interpolated variable with a suffix' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, 'foo'],
          [:STRING, 'bar'],
        ]
      end

      it 'creates a tokenised string with an interpolated variable' do
        expect(tokens).to have(3).tokens
        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'foo',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQPOST,
          value: 'bar',
          line: 1,
          column: 7,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"${foo}bar"')
      end
    end

    context 'an interpolated variable surrounded by string segments' do
      let(:segments) do
        [
          [:STRING, 'foo'],
          [:INTERP, 'bar'],
          [:STRING, 'baz'],
        ]
      end

      it 'creates a tokenised string with an interpolated variable' do
        expect(tokens).to have(3).tokens
        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: 'foo',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'bar',
          line: 1,
          column: 7,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQPOST,
          value: 'baz',
          line: 1,
          column: 10,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"foo${bar}baz"')
      end
    end

    context 'multiple interpolated variables with surrounding text' do
      let(:segments) do
        [
          [:STRING, 'foo'],
          [:INTERP, 'bar'],
          [:STRING, 'baz'],
          [:INTERP, 'gronk'],
          [:STRING, 'meh'],
        ]
      end

      it 'creates a tokenised string with the interpolated variables' do
        expect(tokens).to have(5).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: 'foo',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'bar',
          line: 1,
          column: 7,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQMID,
          value: 'baz',
          line: 1,
          column: 10,
        )
        expect(tokens[3]).to have_attributes(
          type: :VARIABLE,
          value: 'gronk',
          line: 1,
          column: 16,
        )
        expect(tokens[4]).to have_attributes(
          type: :DQPOST,
          value: 'meh',
          line: 1,
          column: 21,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"foo${bar}baz${gronk}meh"')
      end
    end

    context 'only a single interpolated variable' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, 'foo'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(3).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'foo',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 7,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"${foo}"')
      end
    end

    context 'treats a variable named the same as the keyword as a variable' do
      PuppetLint::Lexer::KEYWORDS.each_key do |keyword|
        context "for '#{keyword}'" do
          let(:segments) do
            [
              [:STRING, ''],
              [:INTERP, keyword],
              [:STRING, ''],
            ]
          end

          it 'creates a tokenised string' do
            expect(tokens).to have(3).tokens

            expect(tokens[0]).to have_attributes(
              type: :DQPRE,
              value: '',
              line: 1,
              column: 1,
            )
            expect(tokens[1]).to have_attributes(
              type: :VARIABLE,
              value: keyword,
              line: 1,
              column: 4,
            )
            expect(tokens[2]).to have_attributes(
              type: :DQPOST,
              value: '',
              line: 1,
              column: keyword.size + 4,
            )
          end

          it 'can render the result back into a manifest' do
            expect(manifest).to eq("\"${#{keyword}}\"")
          end
        end
      end
    end

    context 'an interpolated variable with an unnecessary $' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, '$bar'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(3).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'bar',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 8,
        )
      end

      it 'includes the extra $ in the rendered manifest' do
        expect(manifest).to eq('"${$bar}"')
      end
    end

    context 'an interpolated variable with an array reference' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, 'foo[bar][baz]'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(9).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'foo',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :LBRACK,
          value: '[',
          line: 1,
          column: 7,
        )
        expect(tokens[3]).to have_attributes(
          type: :NAME,
          value: 'bar',
          line: 1,
          column: 8,
        )
        expect(tokens[4]).to have_attributes(
          type: :RBRACK,
          value: ']',
          line: 1,
          column: 11,
        )
        expect(tokens[5]).to have_attributes(
          type: :LBRACK,
          value: '[',
          line: 1,
          column: 12,
        )
        expect(tokens[6]).to have_attributes(
          type: :NAME,
          value: 'baz',
          line: 1,
          column: 13,
        )
        expect(tokens[7]).to have_attributes(
          type: :RBRACK,
          value: ']',
          line: 1,
          column: 16,
        )
        expect(tokens[8]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 17,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"${foo[bar][baz]}"')
      end
    end

    context 'multiple interpreted variables' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, 'foo'],
          [:STRING, ''],
          [:INTERP, 'bar'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(5).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'foo',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQMID,
          value: '',
          line: 1,
          column: 7,
        )
        expect(tokens[3]).to have_attributes(
          type: :VARIABLE,
          value: 'bar',
          line: 1,
          column: 10,
        )
        expect(tokens[4]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 13,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"${foo}${bar}"')
      end
    end

    context 'an unenclosed variable' do
      let(:segments) do
        [
          [:STRING, ''],
          [:UNENC_VAR, '$foo'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(3).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :UNENC_VARIABLE,
          value: 'foo',
          line: 1,
          column: 2,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 6,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"$foo"')
      end
    end

    context 'an interpolation with a nested single quote string' do
      let(:segments) do
        [
          [:STRING, 'string with '],
          [:INTERP, "'a nested single quoted string'"],
          [:STRING, ' inside it'],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(3).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: 'string with ',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :SSTRING,
          value: 'a nested single quoted string',
          line: 1,
          column: 16,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQPOST,
          value: ' inside it',
          line: 1,
          column: 47,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq(%("string with ${'a nested single quoted string'} inside it"))
      end
    end

    context 'an interpolation with a nested math expression' do
      let(:segments) do
        [
          [:STRING, 'string with '],
          [:INTERP, '(3+5)/4'],
          [:STRING, ' nested math'],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(9).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: 'string with ',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :LPAREN,
          value: '(',
          line: 1,
          column: 16,
        )
        expect(tokens[2]).to have_attributes(
          type: :NUMBER,
          value: '3',
          line: 1,
          column: 17,
        )
        expect(tokens[3]).to have_attributes(
          type: :PLUS,
          value: '+',
          line: 1,
          column: 18,
        )
        expect(tokens[4]).to have_attributes(
          type: :NUMBER,
          value: '5',
          line: 1,
          column: 19,
        )
        expect(tokens[5]).to have_attributes(
          type: :RPAREN,
          value: ')',
          line: 1,
          column: 20,
        )
        expect(tokens[6]).to have_attributes(
          type: :DIV,
          value: '/',
          line: 1,
          column: 21,
        )
        expect(tokens[7]).to have_attributes(
          type: :NUMBER,
          value: '4',
          line: 1,
          column: 22,
        )
        expect(tokens[8]).to have_attributes(
          type: :DQPOST,
          value: ' nested math',
          line: 1,
          column: 23,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"string with ${(3+5)/4} nested math"')
      end
    end

    context 'an interpolation with a nested array' do
      let(:segments) do
        [
          [:STRING, 'string with '],
          [:INTERP, "['an array ', $v2]"],
          [:STRING, ' in it'],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(8).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: 'string with ',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :LBRACK,
          value: '[',
          line: 1,
          column: 16,
        )
        expect(tokens[2]).to have_attributes(
          type: :SSTRING,
          value: 'an array ',
          line: 1,
          column: 17,
        )
        expect(tokens[3]).to have_attributes(
          type: :COMMA,
          value: ',',
          line: 1,
          column: 28,
        )
        expect(tokens[4]).to have_attributes(
          type: :WHITESPACE,
          value: ' ',
          line: 1,
          column: 29,
        )
        expect(tokens[5]).to have_attributes(
          type: :VARIABLE,
          value: 'v2',
          line: 1,
          column: 30,
        )
        expect(tokens[6]).to have_attributes(
          type: :RBRACK,
          value: ']',
          line: 1,
          column: 33,
        )
        expect(tokens[7]).to have_attributes(
          type: :DQPOST,
          value: ' in it',
          line: 1,
          column: 34,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq(%("string with ${['an array ', $v2]} in it"))
      end
    end

    context 'multiple unenclosed variables' do
      let(:segments) do
        [
          [:STRING, ''],
          [:UNENC_VAR, '$foo'],
          [:STRING, ''],
          [:UNENC_VAR, '$bar'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(5).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :UNENC_VARIABLE,
          value: 'foo',
          line: 1,
          column: 2,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQMID,
          value: '',
          line: 1,
          column: 6,
        )
        expect(tokens[3]).to have_attributes(
          type: :UNENC_VARIABLE,
          value: 'bar',
          line: 1,
          column: 6,
        )
        expect(tokens[4]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 10,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"$foo$bar"')
      end
    end

    context 'an unenclosed variable with a trailing $' do
      let(:segments) do
        [
          [:STRING, 'foo'],
          [:UNENC_VAR, '$bar'],
          [:STRING, '$'],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(3).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: 'foo',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :UNENC_VARIABLE,
          value: 'bar',
          line: 1,
          column: 5,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQPOST,
          value: '$',
          line: 1,
          column: 9,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"foo$bar$"')
      end
    end

    context 'an interpolation with a complex function chain' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, 'key'],
          [:STRING, ' '],
          [:INTERP, 'flatten([$value]).join("\nkey ")'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(15).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'key',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :DQMID,
          value: ' ',
          line: 1,
          column: 7,
        )
        expect(tokens[3]).to have_attributes(
          type: :FUNCTION_NAME,
          value: 'flatten',
          line: 1,
          column: 11,
        )
        expect(tokens[4]).to have_attributes(
          type: :LPAREN,
          value: '(',
          line: 1,
          column: 18,
        )
        expect(tokens[5]).to have_attributes(
          type: :LBRACK,
          value: '[',
          line: 1,
          column: 19,
        )
        expect(tokens[6]).to have_attributes(
          type: :VARIABLE,
          value: 'value',
          line: 1,
          column: 20,
        )
        expect(tokens[7]).to have_attributes(
          type: :RBRACK,
          value: ']',
          line: 1,
          column: 26,
        )
        expect(tokens[8]).to have_attributes(
          type: :RPAREN,
          value: ')',
          line: 1,
          column: 27,
        )
        expect(tokens[9]).to have_attributes(
          type: :DOT,
          value: '.',
          line: 1,
          column: 28,
        )
        expect(tokens[10]).to have_attributes(
          type: :FUNCTION_NAME,
          value: 'join',
          line: 1,
          column: 29,
        )
        expect(tokens[11]).to have_attributes(
          type: :LPAREN,
          value: '(',
          line: 1,
          column: 33,
        )
        expect(tokens[12]).to have_attributes(
          type: :STRING,
          value: '\nkey ',
          line: 1,
          column: 34,
        )
        expect(tokens[13]).to have_attributes(
          type: :RPAREN,
          value: ')',
          line: 1,
          column: 42,
        )
        expect(tokens[14]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 43,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"${key} ${flatten([$value]).join("\nkey ")}"')
      end
    end

    context 'nested interpolations' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, 'facts["network_${iface}"]'],
          [:STRING, '/'],
          [:INTERP, 'facts["netmask_${iface}"]'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(15).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'facts',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :LBRACK,
          value: '[',
          line: 1,
          column: 9,
        )
        expect(tokens[3]).to have_attributes(
          type: :DQPRE,
          value: 'network_',
          line: 1,
          column: 10,
        )
        expect(tokens[4]).to have_attributes(
          type: :VARIABLE,
          value: 'iface',
          line: 1,
          column: 21,
        )
        expect(tokens[5]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 26,
        )
        expect(tokens[6]).to have_attributes(
          type: :RBRACK,
          value: ']',
          line: 1,
          column: 28,
        )
        expect(tokens[7]).to have_attributes(
          type: :DQMID,
          value: '/',
          line: 1,
          column: 29,
        )
        expect(tokens[8]).to have_attributes(
          type: :VARIABLE,
          value: 'facts',
          line: 1,
          column: 33,
        )
        expect(tokens[9]).to have_attributes(
          type: :LBRACK,
          value: '[',
          line: 1,
          column: 38,
        )
        expect(tokens[10]).to have_attributes(
          type: :DQPRE,
          value: 'netmask_',
          line: 1,
          column: 39,
        )
        expect(tokens[11]).to have_attributes(
          type: :VARIABLE,
          value: 'iface',
          line: 1,
          column: 50,
        )
        expect(tokens[12]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 55,
        )
        expect(tokens[13]).to have_attributes(
          type: :RBRACK,
          value: ']',
          line: 1,
          column: 57,
        )
        expect(tokens[14]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 58,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"${facts["network_${iface}"]}/${facts["netmask_${iface}"]}"')
      end
    end

    context 'interpolation with nested braces' do
      let(:segments) do
        [
          [:STRING, ''],
          [:INTERP, '$foo.map |$bar| { something($bar) }'],
          [:STRING, ''],
        ]
      end

      it 'creates a tokenised string' do
        expect(tokens).to have(18).tokens

        expect(tokens[0]).to have_attributes(
          type: :DQPRE,
          value: '',
          line: 1,
          column: 1,
        )
        expect(tokens[1]).to have_attributes(
          type: :VARIABLE,
          value: 'foo',
          line: 1,
          column: 4,
        )
        expect(tokens[2]).to have_attributes(
          type: :DOT,
          value: '.',
          line: 1,
          column: 8,
        )
        expect(tokens[3]).to have_attributes(
          type: :NAME,
          value: 'map',
          line: 1,
          column: 9,
        )
        expect(tokens[4]).to have_attributes(
          type: :WHITESPACE,
          value: ' ',
          line: 1,
          column: 12,
        )
        expect(tokens[5]).to have_attributes(
          type: :PIPE,
          value: '|',
          line: 1,
          column: 13,
        )
        expect(tokens[6]).to have_attributes(
          type: :VARIABLE,
          value: 'bar',
          line: 1,
          column: 14,
        )
        expect(tokens[7]).to have_attributes(
          type: :PIPE,
          value: '|',
          line: 1,
          column: 18,
        )
        expect(tokens[8]).to have_attributes(
          type: :WHITESPACE,
          value: ' ',
          line: 1,
          column: 19,
        )
        expect(tokens[9]).to have_attributes(
          type: :LBRACE,
          value: '{',
          line: 1,
          column: 20,
        )
        expect(tokens[10]).to have_attributes(
          type: :WHITESPACE,
          value: ' ',
          line: 1,
          column: 21,
        )
        expect(tokens[11]).to have_attributes(
          type: :FUNCTION_NAME,
          value: 'something',
          line: 1,
          column: 22,
        )
        expect(tokens[12]).to have_attributes(
          type: :LPAREN,
          value: '(',
          line: 1,
          column: 31,
        )
        expect(tokens[13]).to have_attributes(
          type: :VARIABLE,
          value: 'bar',
          line: 1,
          column: 32,
        )
        expect(tokens[14]).to have_attributes(
          type: :RPAREN,
          value: ')',
          line: 1,
          column: 36,
        )
        expect(tokens[15]).to have_attributes(
          type: :WHITESPACE,
          value: ' ',
          line: 1,
          column: 37,
        )
        expect(tokens[16]).to have_attributes(
          type: :RBRACE,
          value: '}',
          line: 1,
          column: 38,
        )
        expect(tokens[17]).to have_attributes(
          type: :DQPOST,
          value: '',
          line: 1,
          column: 39,
        )
      end

      it 'can render the result back into a manifest' do
        expect(manifest).to eq('"${$foo.map |$bar| { something($bar) }}"')
      end
    end
  end

  context ':STRING / :DQ' do
    it 'handles a string with newline characters' do
      # rubocop:disable Layout/TrailingWhitespace
      manifest = <<END
  exec {
    'do-something':
      command     => "echo > /home/bar/.token; 
                                kdestroy; 
                                kinit ${pseudouser}@EXAMPLE.COM -kt ${keytab_path}; 
                                test $(klist | egrep '^Default principal:' | sed 's/Default principal:\\s//') = '${pseudouser}'@EXAMPLE.COM",
      refreshonly => true;
  }
END
      # rubocop:enable Layout/TrailingWhitespace
      tokens = lexer.tokenise(manifest)

      expect(tokens.length).to eq(34)

      expect(tokens[0].type).to eq(:WHITESPACE)
      expect(tokens[0].value).to eq('  ')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:NAME)
      expect(tokens[1].value).to eq('exec')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(3)
      expect(tokens[2].type).to eq(:WHITESPACE)
      expect(tokens[2].value).to eq(' ')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(7)
      expect(tokens[3].type).to eq(:LBRACE)
      expect(tokens[3].value).to eq('{')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(8)
      expect(tokens[4].type).to eq(:NEWLINE)
      expect(tokens[4].value).to eq("\n")
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(9)
      expect(tokens[5].type).to eq(:INDENT)
      expect(tokens[5].value).to eq('    ')
      expect(tokens[5].line).to eq(2)
      expect(tokens[5].column).to eq(1)
      expect(tokens[6].type).to eq(:SSTRING)
      expect(tokens[6].value).to eq('do-something')
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(5)
      expect(tokens[7].type).to eq(:COLON)
      expect(tokens[7].value).to eq(':')
      expect(tokens[7].line).to eq(2)
      expect(tokens[7].column).to eq(19)
      expect(tokens[8].type).to eq(:NEWLINE)
      expect(tokens[8].value).to eq("\n")
      expect(tokens[8].line).to eq(2)
      expect(tokens[8].column).to eq(20)
      expect(tokens[9].type).to eq(:INDENT)
      expect(tokens[9].value).to eq('      ')
      expect(tokens[9].line).to eq(3)
      expect(tokens[9].column).to eq(1)
      expect(tokens[10].type).to eq(:NAME)
      expect(tokens[10].value).to eq('command')
      expect(tokens[10].line).to eq(3)
      expect(tokens[10].column).to eq(7)
      expect(tokens[11].type).to eq(:WHITESPACE)
      expect(tokens[11].value).to eq('     ')
      expect(tokens[11].line).to eq(3)
      expect(tokens[11].column).to eq(14)
      expect(tokens[12].type).to eq(:FARROW)
      expect(tokens[12].value).to eq('=>')
      expect(tokens[12].line).to eq(3)
      expect(tokens[12].column).to eq(19)
      expect(tokens[13].type).to eq(:WHITESPACE)
      expect(tokens[13].value).to eq(' ')
      expect(tokens[13].line).to eq(3)
      expect(tokens[13].column).to eq(21)
      expect(tokens[14].type).to eq(:DQPRE)
      expect(tokens[14].value).to eq("echo > /home/bar/.token; \n                                kdestroy; \n                                kinit ")
      expect(tokens[14].line).to eq(3)
      expect(tokens[14].column).to eq(22)
      expect(tokens[15].type).to eq(:VARIABLE)
      expect(tokens[15].value).to eq('pseudouser')
      expect(tokens[15].line).to eq(5)
      expect(tokens[15].column).to eq(41)
      expect(tokens[16].type).to eq(:DQMID)
      expect(tokens[16].value).to eq('@EXAMPLE.COM -kt ')
      expect(tokens[16].line).to eq(5)
      expect(tokens[16].column).to eq(51)
      expect(tokens[17].type).to eq(:VARIABLE)
      expect(tokens[17].value).to eq('keytab_path')
      expect(tokens[17].line).to eq(5)
      expect(tokens[17].column).to eq(71)
      expect(tokens[18].type).to eq(:DQMID)
      expect(tokens[18].value).to eq("; \n                                test $(klist | egrep '^Default principal:' | sed 's/Default principal:\\s//') = '")
      expect(tokens[18].line).to eq(5)
      expect(tokens[18].column).to eq(82)
      expect(tokens[19].type).to eq(:VARIABLE)
      expect(tokens[19].value).to eq('pseudouser')
      expect(tokens[19].line).to eq(6)
      expect(tokens[19].column).to eq(115)
      expect(tokens[20].type).to eq(:DQPOST)
      expect(tokens[20].value).to eq("'@EXAMPLE.COM")
      expect(tokens[20].line).to eq(6)
      expect(tokens[20].column).to eq(125)
      expect(tokens[21].type).to eq(:COMMA)
      expect(tokens[21].value).to eq(',')
      expect(tokens[21].line).to eq(6)
      expect(tokens[21].column).to eq(140)
      expect(tokens[22].type).to eq(:NEWLINE)
      expect(tokens[22].value).to eq("\n")
      expect(tokens[22].line).to eq(6)
      expect(tokens[22].column).to eq(141)
      expect(tokens[23].type).to eq(:INDENT)
      expect(tokens[23].value).to eq('      ')
      expect(tokens[23].line).to eq(7)
      expect(tokens[23].column).to eq(1)
      expect(tokens[24].type).to eq(:NAME)
      expect(tokens[24].value).to eq('refreshonly')
      expect(tokens[24].line).to eq(7)
      expect(tokens[24].column).to eq(7)
      expect(tokens[25].type).to eq(:WHITESPACE)
      expect(tokens[25].value).to eq(' ')
      expect(tokens[25].line).to eq(7)
      expect(tokens[25].column).to eq(18)
      expect(tokens[26].type).to eq(:FARROW)
      expect(tokens[26].value).to eq('=>')
      expect(tokens[26].line).to eq(7)
      expect(tokens[26].column).to eq(19)
      expect(tokens[27].type).to eq(:WHITESPACE)
      expect(tokens[27].value).to eq(' ')
      expect(tokens[27].line).to eq(7)
      expect(tokens[27].column).to eq(21)
      expect(tokens[28].type).to eq(:TRUE)
      expect(tokens[28].value).to eq('true')
      expect(tokens[28].line).to eq(7)
      expect(tokens[28].column).to eq(22)
      expect(tokens[29].type).to eq(:SEMIC)
      expect(tokens[29].value).to eq(';')
      expect(tokens[29].line).to eq(7)
      expect(tokens[29].column).to eq(26)
      expect(tokens[30].type).to eq(:NEWLINE)
      expect(tokens[30].value).to eq("\n")
      expect(tokens[30].line).to eq(7)
      expect(tokens[30].column).to eq(27)
      expect(tokens[31].type).to eq(:INDENT)
      expect(tokens[31].value).to eq('  ')
      expect(tokens[31].line).to eq(8)
      expect(tokens[31].column).to eq(1)
      expect(tokens[32].type).to eq(:RBRACE)
      expect(tokens[32].value).to eq('}')
      expect(tokens[32].line).to eq(8)
      expect(tokens[32].column).to eq(3)
      expect(tokens[33].type).to eq(:NEWLINE)
      expect(tokens[33].value).to eq("\n")
      expect(tokens[33].line).to eq(8)
      expect(tokens[33].column).to eq(4)
    end

    it 'calculates the column number correctly after an enclosed variable' do
      token = lexer.tokenise('  "${foo}" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(12)
    end

    it 'calculates the column number correctly after an enclosed variable starting with a string' do
      token = lexer.tokenise('  "bar${foo}" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(15)
    end

    it 'calculates the column number correctly after an enclosed variable ending with a string' do
      token = lexer.tokenise('  "${foo}bar" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(15)
    end

    it 'calculates the column number correctly after an enclosed variable surround by a string' do
      token = lexer.tokenise('  "foo${bar}baz" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(18)
    end

    it 'does not enclose variable with a chained function call' do
      manifest = '"This is ${a.test}"'
      tokens = lexer.tokenise(manifest)
      expect(tokens.map(&:to_manifest).join('')).to eq(manifest)
    end
  end

  ['case', 'class', 'default', 'define', 'import', 'if', 'elsif', 'else', 'inherits', 'node', 'and', 'or', 'undef', 'true', 'false', 'in', 'unless'].each do |keyword|
    it "handles '#{keyword}' as a keyword" do
      token = lexer.tokenise(keyword).first
      expect(token.type).to eq(keyword.upcase.to_sym)
      expect(token.value).to eq(keyword)
    end
  end

  [
    [:LBRACK, '['],
    [:RBRACK, ']'],
    [:LBRACE, '{'],
    [:RBRACE, '}'],
    [:LPAREN, '('],
    [:RPAREN, ')'],
    [:EQUALS, '='],
    [:ISEQUAL, '=='],
    [:GREATEREQUAL, '>='],
    [:GREATERTHAN, '>'],
    [:LESSTHAN, '<'],
    [:LESSEQUAL, '<='],
    [:NOTEQUAL, '!='],
    [:NOT, '!'],
    [:COMMA, ','],
    [:DOT, '.'],
    [:COLON, ':'],
    [:AT, '@'],
    [:LLCOLLECT, '<<|'],
    [:RRCOLLECT, '|>>'],
    [:LCOLLECT, '<|'],
    [:RCOLLECT, '|>'],
    [:SEMIC, ';'],
    [:QMARK, '?'],
    [:BACKSLASH, '\\'],
    [:FARROW, '=>'],
    [:PARROW, '+>'],
    [:APPENDS, '+='],
    [:PLUS, '+'],
    [:MINUS, '-'],
    [:DIV, '/'],
    [:TIMES, '*'],
    [:MODULO, '%'],
    [:PIPE, '|'],
    [:LSHIFT, '<<'],
    [:RSHIFT, '>>'],
    [:MATCH, '=~'],
    [:NOMATCH, '!~'],
    [:IN_EDGE, '->'],
    [:OUT_EDGE, '<-'],
    [:IN_EDGE_SUB, '~>'],
    [:OUT_EDGE_SUB, '<~'],
    [:NEWLINE, "\r"],
    [:NEWLINE, "\n"],
    [:NEWLINE, "\r\n"],
  ].each do |name, string|
    it "has a token named '#{name}'" do
      token = lexer.tokenise(string).first
      expect(token.type).to eq(name)
      expect(token.value).to eq(string)
    end
  end

  context ':TYPE' do
    it 'matches Data Types' do
      token = lexer.tokenise('Integer').first
      expect(token.type).to eq(:TYPE)
      expect(token.value).to eq('Integer')
    end

    it 'matches Catalog Types' do
      token = lexer.tokenise('Resource').first
      expect(token.type).to eq(:TYPE)
      expect(token.value).to eq('Resource')
    end

    it 'matches Abstract Types' do
      token = lexer.tokenise('Collection').first
      expect(token.type).to eq(:TYPE)
      expect(token.value).to eq('Collection')
    end

    describe 'Platform Types' do
      it 'matches Callable' do
        token = lexer.tokenise('Callable').first
        expect(token.type).to eq(:TYPE)
        expect(token.value).to eq('Callable')
      end
      it 'matches Sensitive' do
        token = lexer.tokenise('Sensitive').first
        expect(token.type).to eq(:TYPE)
        expect(token.value).to eq('Sensitive')
      end
    end
  end

  context ':HEREDOC without interpolation' do
    it 'parses a simple heredoc' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @(myheredoc)
        SOMETHING
        ELSE
        :
        |-myheredoc
      END
      tokens = lexer.tokenise(manifest)

      expect(tokens.length).to eq(8)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('myheredoc')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(20)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  SOMETHING\n  ELSE\n  :\n  ")
      expect(tokens[6].raw).to eq("  SOMETHING\n  ELSE\n  :\n  |-myheredoc")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(14)
    end

    it 'does not interpolate the contents of the heredoc' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @(myheredoc)
        SOMETHING
        ${else}
        :
        |-myheredoc
      END
      tokens = lexer.tokenise(manifest)

      expect(tokens.length).to eq(8)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('myheredoc')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(20)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  SOMETHING\n  ${else}\n  :\n  ")
      expect(tokens[6].raw).to eq("  SOMETHING\n  ${else}\n  :\n  |-myheredoc")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].value).to eq("\n")
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(14)
    end

    it 'handles multiple heredoc declarations on a single line' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = "${@(end1)} ${@(end2)}"
        foo
        |-end1
        bar
        |-end2
      END
      tokens = lexer.tokenise(manifest)

      expect(tokens.length).to eq(14)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:DQPRE)
      expect(tokens[4].value).to eq('')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:HEREDOC_OPEN)
      expect(tokens[5].value).to eq('end1')
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(11)
      expect(tokens[6].type).to eq(:DQMID)
      expect(tokens[6].value).to eq(' ')
      expect(tokens[6].line).to eq(1)
      expect(tokens[6].column).to eq(18)
      expect(tokens[7].type).to eq(:HEREDOC_OPEN)
      expect(tokens[7].value).to eq('end2')
      expect(tokens[7].line).to eq(1)
      expect(tokens[7].column).to eq(22)
      expect(tokens[8].type).to eq(:DQPOST)
      expect(tokens[8].value).to eq('')
      expect(tokens[8].line).to eq(1)
      expect(tokens[8].column).to eq(29)
      expect(tokens[9].type).to eq(:NEWLINE)
      expect(tokens[9].value).to eq("\n")
      expect(tokens[9].line).to eq(1)
      expect(tokens[9].column).to eq(31)
      expect(tokens[10].type).to eq(:HEREDOC)
      expect(tokens[10].value).to eq("  foo\n  ")
      expect(tokens[10].raw).to eq("  foo\n  |-end1")
      expect(tokens[10].line).to eq(2)
      expect(tokens[10].column).to eq(1)
      expect(tokens[11].type).to eq(:NEWLINE)
      expect(tokens[11].value).to eq("\n")
      expect(tokens[11].line).to eq(3)
      expect(tokens[11].column).to eq(9)
      expect(tokens[12].type).to eq(:HEREDOC)
      expect(tokens[12].value).to eq("  bar\n  ")
      expect(tokens[12].raw).to eq("  bar\n  |-end2")
      expect(tokens[12].line).to eq(4)
      expect(tokens[12].column).to eq(1)
      expect(tokens[13].type).to eq(:NEWLINE)
      expect(tokens[13].value).to eq("\n")
      expect(tokens[13].line).to eq(5)
      expect(tokens[13].column).to eq(9)
    end

    it 'handles a heredoc that specifies a syntax' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("end":json/)
        {
          "foo": "bar"
        }
        |-end
      END

      tokens = lexer.tokenise(manifest)

      expect(tokens.length).to eq(8)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('"end":json/')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(22)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  {\n    \"foo\": \"bar\"\n  }\n  ")
      expect(tokens[6].raw).to eq("  {\n    \"foo\": \"bar\"\n  }\n  |-end")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].value).to eq("\n")
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(8)
    end

    it 'handles a heredoc with spaces in the tag' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("myheredoc"     /)
        foo
        |-myheredoc
      END
      tokens = lexer.tokenise(manifest)
      expect(tokens.length).to eq(8)

      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('"myheredoc"     /')
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  foo\n  ")
    end

    it 'handles a heredoc with no indentation' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @(EOT)
      something
      EOT
      END
      tokens = lexer.tokenise(manifest)

      expect(tokens.length).to eq(8)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('EOT')
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq('something')
    end
  end

  context ':HEREDOC with interpolation' do
    it 'parses a heredoc with no interpolated values as a :HEREDOC' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("myheredoc"/)
        SOMETHING
        ELSE
        :
        |-myheredoc
      END
      tokens = lexer.tokenise(manifest)

      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('"myheredoc"/')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(23)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  SOMETHING\n  ELSE\n  :\n  ")
      expect(tokens[6].raw).to eq("  SOMETHING\n  ELSE\n  :\n  |-myheredoc")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].value).to eq("\n")
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(14)
    end

    it 'parses a heredoc with interpolated values' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("myheredoc"/)
        SOMETHING
        ${here}
        AND :
        $another
        THING
        | myheredoc
      END

      tokens = lexer.tokenise(manifest)
      expect(tokens.map(&:to_manifest).join('')).to eq(manifest)

      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('"myheredoc"/')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(23)
      expect(tokens[6].type).to eq(:HEREDOC_PRE)
      expect(tokens[6].value).to eq("  SOMETHING\n  ")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:VARIABLE)
      expect(tokens[7].value).to eq('here')
      expect(tokens[7].line).to eq(3)
      expect(tokens[7].column).to eq(5)
      expect(tokens[7].to_manifest).to eq('here')
      expect(tokens[8].type).to eq(:HEREDOC_MID)
      expect(tokens[8].value).to eq("\n  AND :\n  ")
      expect(tokens[8].line).to eq(3)
      expect(tokens[8].column).to eq(9)
      expect(tokens[8].to_manifest).to eq("}\n  AND :\n  ")
      expect(tokens[9].type).to eq(:UNENC_VARIABLE)
      expect(tokens[9].value).to eq('another')
      expect(tokens[9].line).to eq(5)
      expect(tokens[9].column).to eq(3)
      expect(tokens[9].to_manifest).to eq('$another')
      expect(tokens[10].type).to eq(:HEREDOC_POST)
      expect(tokens[10].value).to eq("\n  THING\n  ")
      expect(tokens[10].raw).to eq("\n  THING\n  | myheredoc")
      expect(tokens[10].line).to eq(5)
      expect(tokens[10].column).to eq(11)
    end

    it 'does not remove the unnecessary $ from enclosed variables' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("myheredoc"/)
        ${$myvar}
        |-myheredoc
      END
      tokens = lexer.tokenise(manifest)

      expect(tokens.length).to eq(10)

      expect(tokens[7].type).to eq(:VARIABLE)
      expect(tokens[7].value).to eq('myvar')
      expect(tokens[7].raw).to eq('$myvar')
      expect(tokens[7].to_manifest).to eq('$myvar')

      expect(tokens.map(&:to_manifest).join('')).to eq(manifest)
    end
  end

  context ':CLASSREF' do
    it 'matches single capitalised alphanumeric term' do
      token = lexer.tokenise('One').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('One')
    end

    it 'matches two capitalised alphanumeric terms sep by ::' do
      token = lexer.tokenise('One::Two').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('One::Two')
    end

    it 'matches many capitalised alphanumeric terms sep by ::' do
      token = lexer.tokenise('One::Two::Three::Four::Five').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('One::Two::Three::Four::Five')
    end

    it 'matches capitalised terms prefixed by ::' do
      token = lexer.tokenise('::One').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('::One')
    end

    it 'matches terms that start with Types' do
      token = lexer.tokenise('Regexp_foo').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('Regexp_foo')
    end
  end

  context ':NAME' do
    it 'matches lowercase alphanumeric terms' do
      token = lexer.tokenise('one-two').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('one-two')
    end

    it 'matches lowercase alphanumeric terms sep by ::' do
      token = lexer.tokenise('one::two').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('one::two')
    end

    it 'matches many lowercase alphanumeric terms sep by ::' do
      token = lexer.tokenise('one::two::three::four::five').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('one::two::three::four::five')
    end

    it 'matches lowercase alphanumeric terms prefixed by ::' do
      token = lexer.tokenise('::1one::2two::3three').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('::1one::2two::3three')
    end

    it 'matches barewords beginning with an underscore' do
      token = lexer.tokenise('_bareword').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('_bareword')
    end
  end

  context ':FUNCTION_NAME' do
    it 'matches when a :NAME is followed by a :LPAREN' do
      token = lexer.tokenise('my_function(').first
      expect(token.type).to eq(:FUNCTION_NAME)
      expect(token.value).to eq('my_function')
    end
  end

  context ':NUMBER' do
    it 'matches numeric terms' do
      token = lexer.tokenise('1234567890').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('1234567890')
    end

    it 'matches float terms' do
      token = lexer.tokenise('12345.6789').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('12345.6789')
    end

    it 'matches hexadecimal terms' do
      token = lexer.tokenise('0xCAFE1029').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('0xCAFE1029')
    end

    [
      '10e23',
      '1.234e5',
    ].each do |f|
      it 'matches float with exponent terms' do
        token = lexer.tokenise(f).first
        expect(token.type).to eq(:NUMBER)
        expect(token.value).to eq(f)
      end
    end

    it 'matches float with negative exponent terms' do
      token = lexer.tokenise('10e-23').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('10e-23')
    end
  end

  context ':COMMENT' do
    it 'matches everything on a line after #' do
      token = lexer.tokenise('foo # bar baz')[2]
      expect(token.type).to eq(:COMMENT)
      expect(token.value).to eq(' bar baz')
    end

    it 'does not include DOS line endings in the comment value' do
      tokens = lexer.tokenise("foo # bar baz\r\n")

      expect(tokens[2]).to have_attributes(type: :COMMENT, value: ' bar baz')
      expect(tokens[3]).to have_attributes(type: :NEWLINE, value: "\r\n")
    end

    it 'does not include Unix line endings in the comment value' do
      tokens = lexer.tokenise("foo # bar baz\n")

      expect(tokens[2]).to have_attributes(type: :COMMENT, value: ' bar baz')
      expect(tokens[3]).to have_attributes(type: :NEWLINE, value: "\n")
    end
  end

  context ':MLCOMMENT' do
    it 'matches comments on a single line' do
      token = lexer.tokenise('/* foo bar */').first
      expect(token.type).to eq(:MLCOMMENT)
      expect(token.value).to eq('foo bar')
    end

    it 'matches comments on multiple lines' do
      token = lexer.tokenise("/* foo\n * bar\n*/").first
      expect(token.type).to eq(:MLCOMMENT)
      expect(token.value).to eq("foo\n bar\n")
    end
  end

  context ':SLASH_COMMENT' do
    it 'matches everyone on a line after //' do
      token = lexer.tokenise('foo // bar baz')[2]
      expect(token.type).to eq(:SLASH_COMMENT)
      expect(token.value).to eq(' bar baz')
    end

    it 'does not include DOS line endings in the comment value' do
      tokens = lexer.tokenise("foo // bar baz\r\n")

      expect(tokens[2]).to have_attributes(type: :SLASH_COMMENT, value: ' bar baz')
      expect(tokens[3]).to have_attributes(type: :NEWLINE, value: "\r\n")
    end

    it 'does not include Unix line endings in the comment value' do
      tokens = lexer.tokenise("foo // bar baz\n")

      expect(tokens[2]).to have_attributes(type: :SLASH_COMMENT, value: ' bar baz')
      expect(tokens[3]).to have_attributes(type: :NEWLINE, value: "\n")
    end
  end

  context ':SSTRING' do
    it 'matches a single quoted string' do
      token = lexer.tokenise("'single quoted string'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string')
    end

    it "matches a single quoted string with an escaped '" do
      token = lexer.tokenise(%q('single quoted string with "\\'"')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\\'"')
    end

    it 'matches a single quoted string with an escaped $' do
      token = lexer.tokenise(%q('single quoted string with "\$"')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\$"')
    end

    it 'matches a single quoted string with an escaped .' do
      token = lexer.tokenise(%q('single quoted string with "\."')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\."')
    end

    it 'matches a single quoted string with an escaped \n' do
      token = lexer.tokenise(%q('single quoted string with "\n"')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\n"')
    end

    # it 'matches a single quoted string with an escaped \' do
    #   token = lexer.tokenise(%q('single quoted string with "\\\\"')).first
    #   expect(token.type).to eq(:SSTRING)
    #   expect(token.value).to eq('single quoted string with "\\\\"')
    # end
    #
    it 'matches an empty string' do
      token = lexer.tokenise("''").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('')
    end

    it 'matches an empty string ending with \\' do
      token = lexer.tokenise("'foo\\\\'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq(%(foo\\\\))
    end

    it 'matches single quoted string containing a line break' do
      token = lexer.tokenise("'\n'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq("\n")
    end
  end

  context ':REGEX' do
    it 'matches anything enclosed in //' do
      token = lexer.tokenise('/this is a regex/').first
      expect(token.type).to eq(:REGEX)
      expect(token.value).to eq('this is a regex')
    end

    it 'matches even if there is \n in the regex' do
      token = lexer.tokenise("/this is a regex,\ntoo/").first
      expect(token.type).to eq(:REGEX)
      expect(token.value).to eq("this is a regex,\ntoo")
    end

    it 'does not consider \/ to be the end of the regex' do
      token = lexer.tokenise('/this is \/ a regex/').first
      expect(token.type).to eq(:REGEX)
      expect(token.value).to eq('this is \\/ a regex')
    end

    it 'is allowed as a param to a data type' do
      tokens = lexer.tokenise('Foo[/bar/]')
      expect(tokens[2].type).to eq(:REGEX)
      expect(tokens[2].value).to eq('bar')
    end

    it 'is allowed as a param to an optional data type' do
      tokens = lexer.tokenise('Optional[Regexp[/^puppet/]]')
      expect(tokens[4].type).to eq(:REGEX)
      expect(tokens[4].value).to eq('^puppet')
    end

    it 'does not match chained division' do
      tokens = lexer.tokenise('$x = $a/$b/$c')
      expect(tokens.select { |r| r.type == :REGEX }).to be_empty
    end

    it 'properlies parse when regex follows an if' do
      tokens = lexer.tokenise('if /^icinga_service_icon_.*/ in $location_info { }')
      expect(tokens[2].type).to eq(:REGEX)
    end

    it 'properlies parse when a regex follows an elsif' do
      tokens = lexer.tokenise('if /a/ in $location_info { } elsif /b/ in $location_info { }')
      expect(tokens[2].type).to eq(:REGEX)
      expect(tokens[14].type).to eq(:REGEX)
    end

    it 'properlies parse when a regex is provided as a function argument' do
      tokens = lexer.tokenise('$somevar = $other_var.match(/([\w\.]+(:\d+)?(\/\w+)?)(:(\w+))?/)')
      expect(tokens[8].type).to eq(:REGEX)
      expect(tokens[8].value).to eq('([\w\.]+(:\d+)?(\/\w+)?)(:(\w+))?')
    end

    it 'discriminates between division and regexes' do
      tokens = lexer.tokenise('if $a/10==0 or $b=~/{}/')
      expect(tokens[3].type).to eq(:DIV)
      expect(tokens[12].type).to eq(:REGEX)
      expect(tokens[12].value).to eq('{}')
    end
  end

  context ':STRING' do
    it 'parses strings with embedded strings' do
      expect {
        lexer.tokenise('exec { "/bin/echo \"${environment}\"": }')
      }.not_to raise_error
    end

    it 'matches double quoted string containing a line break' do
      token = lexer.tokenise(%("\n")).first
      expect(token.type).to eq(:STRING)
      expect(token.value).to eq("\n")
    end

    it 'handles interpolated values that contain double quotes' do
      manifest = %{"export bar=\\"${join(hiera('test'), "," )}\\""}

      tokens = lexer.tokenise(manifest)
      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('export bar=\"')
      expect(tokens[1].type).to eq(:FUNCTION_NAME)
      expect(tokens[1].value).to eq('join')
      expect(tokens[2].type).to eq(:LPAREN)
      expect(tokens[3].type).to eq(:FUNCTION_NAME)
      expect(tokens[3].value).to eq('hiera')
      expect(tokens[4].type).to eq(:LPAREN)
      expect(tokens[5].type).to eq(:SSTRING)
      expect(tokens[5].value).to eq('test')
      expect(tokens[6].type).to eq(:RPAREN)
      expect(tokens[7].type).to eq(:COMMA)
      expect(tokens[8].type).to eq(:WHITESPACE)
      expect(tokens[8].value).to eq(' ')
      expect(tokens[9].type).to eq(:STRING)
      expect(tokens[9].value).to eq(',')
      expect(tokens[10].type).to eq(:WHITESPACE)
      expect(tokens[10].value).to eq(' ')
      expect(tokens[11].type).to eq(:RPAREN)
      expect(tokens[12].type).to eq(:DQPOST)
      expect(tokens[12].value).to eq('\"')
    end
  end

  context ':WHITESPACE' do
    it 'parses spaces' do
      token = lexer.tokenise(' ').first
      expect(token.type).to eq(:WHITESPACE)
      expect(token.value).to eq(' ')
    end

    it 'parses tabs' do
      token = lexer.tokenise("\t").first
      expect(token.type).to eq(:WHITESPACE)
      expect(token.value).to eq("\t")
    end

    it 'parses unicode spaces', unless: RUBY_VERSION == '1.8.7' do
      token = lexer.tokenise("\xc2\xa0").first
      expect(token.type).to eq(:WHITESPACE)
      expect(token.value).to eq("\xc2\xa0")
    end
  end
end
