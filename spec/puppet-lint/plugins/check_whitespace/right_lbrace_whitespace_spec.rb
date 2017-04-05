require 'spec_helper'

describe 'right_lbrace_whitespace' do
  let(:msg) { 'space needed on right side of opening bracket' }

  context 'with fix disabled' do
    context 'resource with wrong number of spaces between title and bracket' do
      let(:code) { "file {'/tmp/bad3': ensure => file; }"}

      it 'should only detect one problem' do
        expect(problems).to have(1).problem
      end

      it 'should create one warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(6)
      end
    end

    context 'closed empty brackets and newlines should not be a problem' do
      let(:code) { "
        case $ntp::config_dir {
          '/', '/etc', undef: {}
          default: {
            file { $ntp::config_dir:
              ensure  => directory,
            }
          }
        }
    " }

      it 'should not detect any problems' do
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

    context 'resource with wrong number of spaces between title and bracket' do
      let(:code) { "file {'/tmp/bad3': ensure => file; }"}

      let(:fixed) { "file { '/tmp/bad3': ensure => file; }"}

      it 'should only detect one problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(6)
      end

      it 'should adjust the title whitespace' do
        expect(manifest).to eq(fixed) 
      end
    end
    
    context 'closed empty brackets and newlines should not be a problem' do
      let(:code) { "
        case $ntp::config_dir {
          '/', '/etc', undef: {}
          default: {
            file { $ntp::config_dir:
              ensure  => directory,
            }
          }
        }
    " }

      it 'should not detect any problems' do
        expect(problems).to have(0).problem
      end
    end
  end
end
