require 'spec_helper'

describe PuppetLint::Lexer::StringSlurper do
  describe '#parse' do
    subject(:segments) { described_class.new(string).parse }

    context 'when parsing an unterminated string' do
      let(:string) { 'foo' }

      it 'raises an UnterminatedStringError' do
        expect { segments }.to raise_error(described_class::UnterminatedStringError)
      end
    end

    context 'when parsing up to a double quote' do
      let(:string) { 'foo"bar' }

      it 'returns a single segment up to the double quote' do
        expect(segments).to eq([[:STRING, 'foo']])
      end

      context 'and the string is empty' do
        let(:string) { '"' }

        it 'returns a single empty string segment' do
          expect(segments).to eq([[:STRING, '']])
        end
      end

      context 'and the string contains' do
        context 'a newline' do
          let(:string) { %(foo\nbar") }

          it 'includes the newline in the string segment' do
            expect(segments).to eq([[:STRING, "foo\nbar"]])
          end
        end

        context 'a variable and a suffix' do
          let(:string) { '${foo}bar"' }

          it 'puts the variable into an interpolation segment' do
            expect(segments).to eq([
              [:STRING, ''],
              [:INTERP, 'foo'],
              [:STRING, 'bar'],
            ])
          end
        end

        context 'a variable surrounded by text' do
          let(:string) { 'foo${bar}baz"' }

          it 'puts the variable into an interpolation segment' do
            expect(segments).to eq([
              [:STRING, 'foo'],
              [:INTERP, 'bar'],
              [:STRING, 'baz'],
            ])
          end
        end

        context 'multiple variables with surrounding text' do
          let(:string) { 'foo${bar}baz${gronk}meh"' }

          it 'puts each variable into an interpolation segment' do
            expect(segments).to eq([
              [:STRING, 'foo'],
              [:INTERP, 'bar'],
              [:STRING, 'baz'],
              [:INTERP, 'gronk'],
              [:STRING, 'meh'],
            ])
          end
        end

        context 'only an enclosed variable' do
          let(:string) { '${bar}"' }

          it 'puts empty string segments around the interpolated segment' do
            expect(segments).to eq([
              [:STRING, ''],
              [:INTERP, 'bar'],
              [:STRING, ''],
            ])
          end
        end

        context 'an enclosed variable with an unnecessary $' do
          let(:string) { '${$bar}"' }

          it 'does not remove the unnecessary $' do
            expect(segments).to eq([
              [:STRING, ''],
              [:INTERP, '$bar'],
              [:STRING, ''],
            ])
          end
        end

        context 'a variable with an array reference' do
          let(:string) { '${foo[bar][baz]}"' }

          it 'includes the references in the interpolated section' do
            expect(segments).to eq([
              [:STRING, ''],
              [:INTERP, 'foo[bar][baz]'],
              [:STRING, ''],
            ])
          end
        end

        context 'only enclosed variables' do
          let(:string) { '${foo}${bar}"' }

          it 'creates an interpolation section per variable' do
            expect(segments).to eq([
              [:STRING, ''],
              [:INTERP, 'foo'],
              [:STRING, ''],
              [:INTERP, 'bar'],
              [:STRING, ''],
            ])
          end
        end

        context 'an unenclosed variable' do
          let(:string) { '$foo"' }

          it 'creates a special segment for the unenclosed variable' do
            expect(segments).to eq([
              [:STRING, ''],
              [:UNENC_VAR, '$foo'],
              [:STRING, ''],
            ])
          end
        end

        context 'an interpolation with a nested single quoted string' do
          let(:string) { %(string with ${'a nested single quoted string'} inside it") }

          it 'creates an interpolation segment for the nested string' do
            expect(segments).to eq([
              [:STRING, 'string with '],
              [:INTERP, "'a nested single quoted string'"],
              [:STRING, ' inside it'],
            ])
          end
        end

        context 'an interpolation with nested math' do
          let(:string) { 'string with ${(3+5)/4} nested math"' }

          it 'creates an interpolation segment for the nested math' do
            expect(segments).to eq([
              [:STRING, 'string with '],
              [:INTERP, '(3+5)/4'],
              [:STRING, ' nested math'],
            ])
          end
        end

        context 'an interpolation with a nested array' do
          let(:string) { %(string with ${['an array ', $v2]} in it") }

          it 'creates an interpolation segment for the nested array' do
            expect(segments).to eq([
              [:STRING, 'string with '],
              [:INTERP, "['an array ', $v2]"],
              [:STRING, ' in it'],
            ])
          end
        end

        context 'repeated $s' do
          let(:string) { '$$$$"' }

          it 'creates a single string segment' do
            expect(segments).to eq([[:STRING, '$$$$']])
          end
        end

        context 'multiple unenclosed variables' do
          let(:string) { '$foo$bar"' }

          it 'creates a special segment for each unenclosed variable' do
            expect(segments).to eq([
              [:STRING, ''],
              [:UNENC_VAR, '$foo'],
              [:STRING, ''],
              [:UNENC_VAR, '$bar'],
              [:STRING, ''],
            ])
          end
        end

        context 'an unenclosed variable with a trailing $' do
          let(:string) { 'foo$bar$"' }

          it 'places the trailing $ in a string segment' do
            expect(segments).to eq([
              [:STRING, 'foo'],
              [:UNENC_VAR, '$bar'],
              [:STRING, '$'],
            ])
          end
        end

        context 'an unenclosed variable starting with two $s' do
          let(:string) { 'foo$$bar"' }

          it 'includes the preceeding $ in the string segment before the unenclosed variable' do
            expect(segments).to eq([
              [:STRING, 'foo$'],
              [:UNENC_VAR, '$bar'],
              [:STRING, ''],
            ])
          end
        end

        context 'an unenclosed variable with incorrect namespacing' do
          let(:string) { '$foo::::bar"' }

          it 'only includes the valid part of the variable name in the segment' do
            expect(segments).to eq([
              [:STRING, ''],
              [:UNENC_VAR, '$foo'],
              [:STRING, '::::bar'],
            ])
          end
        end
      end
    end
  end
end
