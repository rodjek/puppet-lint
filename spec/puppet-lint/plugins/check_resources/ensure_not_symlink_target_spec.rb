require 'spec_helper'

describe 'ensure_not_symlink_target' do
  let(:msg) { 'symlink target specified in ensure attr' }

  context 'with fix disabled' do
    context 'file resource creating a symlink with seperate target attr' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => link,
            target => '/foo/bar',
          }
        END
      end

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'file resource creating a symlink with target specified in ensure' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => '/foo/bar',
          }
        END
      end

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(23)
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

    context 'file resource creating a symlink with seperate target attr' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => link,
            target => '/foo/bar',
          }
        END
      end

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'does not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'file resource creating a symlink with target specified in ensure' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => '/foo/bar',
          }
        END
      end

      let(:fixed) do
        <<-END
          file { 'foo':
            ensure => symlink,
            target => '/foo/bar',
          }
        END
      end

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the problem' do
        expect(problems).to contain_fixed(msg).on_line(2).in_column(23)
      end

      it 'creates a new target param' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
