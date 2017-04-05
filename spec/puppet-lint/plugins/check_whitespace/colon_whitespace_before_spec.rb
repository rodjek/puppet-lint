require 'spec_helper'

describe 'colon_whitespace_before' do
  let(:msg) { 'there should be no space before a colon' }

  context 'with fix disabled' do
    context 'resource with space between title and colon' do
      let(:code) { "file { '/tmp/bad1' : ensure => file; }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(20)
      end
    end
    
    context 'valid exec command with whitespace before colon' do
      let(:code) { %Q{
        exec { 'set hi noop':
          command => 'unset x; ( x=hi :; echo "$x" )',
        }          
        } 
      }

      it 'should not detect any problem' do
        expect(problems).to have(0).problem
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'resource with space between title and colon' do
      let(:code) { "file { '/tmp/bad1' : ensure => file; }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(20)
      end

      it 'should remove the title whitespace' do
        expect(manifest).to eq("file { '/tmp/bad1': ensure => file; }")
      end
    end
    
    context 'valid exec command with whitespace before colon' do
      let(:code) { %Q{
        exec { 'set hi noop':
          command => 'unset x; ( x=hi :; echo "$x" )',
        }          
        } 
      }

      it 'should not detect any problem' do
        expect(problems).to have(0).problem
      end
    end
  end
end
