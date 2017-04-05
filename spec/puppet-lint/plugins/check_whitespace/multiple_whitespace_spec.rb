require 'spec_helper'

describe 'multiple_whitespace' do
  let(:msg) { 'too many spaces' }

  context 'with fix disabled' do
   context 'incorrect spacing around resource type' do
      let(:code) { "
        file   { '/tmp/bad5': ensure => file; }"
      }

      it 'should only detect one problem' do
        expect(problems).to have(1).problem
      end

      it 'should create one warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(13)
      end
    end

   context 'not detect a problem within strings with multiple spaces' do
      let(:code) { "
        sudo::conf { 'admins':
          priority => 10,
          content  => '%admins   ALL=(ALL)   NOPASSWD: ALL',
        }
    " }

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

    context 'incorrect spacing around resource type' do
      let(:code) { "
        file   { '/tmp/bad5': ensure => file; }"
      }
    
      let(:fixed) { "
        file { '/tmp/bad5': ensure => file; }"
      }
      
      it 'should only detect one problem' do
        expect(problems).to have(1).problem
      end

      it 'should create one warning' do
        expect(problems).to contain_fixed(msg).on_line(2).in_column(13)
      end

      it 'should adjust incorrect resource whitespace' do
        expect(manifest).to eq(fixed)
      end
    end
   
    context 'not detect a problem within strings with multiple spaces' do
      let(:code) { "
        sudo::conf { 'admins':
          priority => 10,
          content  => '%admins   ALL=(ALL)   NOPASSWD: ALL',
        }
    " }

      it 'should not detect any problem' do
        expect(problems).to have(0).problem
      end
    end
  end
end
