require 'spec_helper'

describe 'left_lbrace_whitespace' do
  let(:msg) { 'space needed on left side of opening bracket' }

  context 'with fix disabled' do
   context 'incorrect spacing around resource type' do
      let(:code) { "file{ '/tmp/bad2': ensure => file; }"}

      it 'should detect only one problem' do
        expect(problems).to have(1).problem
      end

      it 'should create one warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(1)
      end
    end
   
    context 'should not detect a problem with json heredoc' do
      let(:code) { %Q{
        $value = 'foo'
        notice @("EOF":json/$)
          {
            "hoge": "${value}"
          }
        |-EOF
           }
      }

      it 'should detect not detect any problem' do
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

    context 'incorrect spacing around resource type' do
      let(:code) { "file{ '/tmp/bad2': ensure => file; }"}
    
      let(:fixed) { "file { '/tmp/bad2': ensure => file; }"}
      
      it 'should detect only one problem' do
        expect(problems).to have(1).problem
      end

      it 'should create one warning' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'should adjust incorrect resource whitespace' do
        expect(manifest).to eq(fixed)
      end
    end
    
    context 'should not detect a problem with json heredoc' do
      let(:code) { %Q{
        $value = 'foo'
        notice @("EOF":json/$)
          {
            "hoge": "${value}"
          }
        |-EOF
           }
      }

      it 'should detect not detect any problem' do
        expect(problems).to have(0).problem
      end
    end
  end
end
