require 'spec_helper'

describe 'only_variable_string' do
  let(:msg) { 'string containing only a variable' }

  context 'with fix disabled' do
    context 'string containing only a variable' do
      let(:code) { '"${foo}"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(4)
      end
    end

    context 'string containing only a variable w/ ref' do
      let(:code) { '"${foo[0]}"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(4)
      end
    end

    context 'string containing only a variable w/ lots of refs' do
      let(:code) { '"${foo[0][aoeuaoeu][bar][999]}"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(4)
      end
    end

    context 'string containing only a variable as a hash key' do
      let(:code) do
        <<-END
          $bar = 'key'
          $foo = {
            \"$bar\" => 1,
          }
        END
      end

      it 'does not detect any problems' do
        expect(problems).to be_empty
      end
    end
  end

  context 'with fix enabled' do
    before(:each) do
      PuppetLint.configuration.fix = true
    end

    after(:each) do
      PuppetLint.configuration.fix = false
    end

    context 'string containing only a variable' do
      let(:code) { '"${foo}"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(4)
      end

      it 'unquotes the variable' do
        expect(manifest).to eq('$foo')
      end
    end

    context 'string contaiting only a variable w/ ref' do
      let(:code) { '"${foo[0]}"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(4)
      end

      it 'unquotes the variable' do
        expect(manifest).to eq('$foo[0]')
      end
    end

    context 'string containing only a variable w/ lots of refs' do
      let(:code) { '"${foo[0][aoeuaoeu][bar][999]}"' }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(4)
      end

      it 'unquotes the variable' do
        expect(manifest).to eq('$foo[0][aoeuaoeu][bar][999]')
      end
    end
  end
end
