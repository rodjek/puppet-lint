require 'spec_helper'

describe 'unquoted_resource_title' do
  let(:msg) { 'unquoted resource title' }

  context 'with fix disabled' do
    context 'quoted resource title on single line resource' do
      let(:code) { "file { 'foo': }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'unquoted resource title on single line resource' do
      let(:code) { 'file { foo: }' }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(8)
      end
    end

    context 'quoted resource title on multi line resource' do
      let(:code) do
        <<-END
          file { 'foo':
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'unquoted resource title on multi line resource' do
      let(:code) do
        <<-END
          file { foo:
          }
        END
      end

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(18)
      end
    end

    context 'condensed resources with quoted titles' do
      let(:code) do
        <<-END
          file {
            'foo': ;
            'bar': ;
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'condensed resources with an unquoted title' do
      let(:code) do
        <<-END
          file {
            'foo': ;
            bar: ;
          }
        END
      end

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(3).in_column(13)
      end
    end

    context 'single line resource with an array of titles (all quoted)' do
      let(:code) { "file { ['foo', 'bar']: }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'resource inside a case statement' do
      let(:code) do
        <<-END
          case $ensure {
            'absent': {
              file { "some_file_${name}":
                ensure => absent,
              }
            }
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'issue #116' do
      let(:code) do
        <<-END
          $config_file_init = $::operatingsystem ? {
            /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/foo',
            default                   => '/etc/sysconfig/foo',
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'case statement' do
      let(:code) do
        <<-END
          case $operatingsystem {
            centos: {
              $version = '1.2.3'
            }
            solaris: {
              $version = '3.2.1'
            }
            default: {
              fail("Module ${module_name} is not supported on ${operatingsystem}")
            }
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
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

    context 'unquoted resource title on single line resource' do
      let(:code) { 'file { foo: }' }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(8)
      end

      it 'should single quote the resource title' do
        expect(manifest).to eq("file { 'foo': }")
      end
    end

    context 'unquoted resource title on multi line resource' do
      let(:code) do
        <<-END
          file { foo:
          }
        END
      end

      let(:fixed) do
        <<-END
          file { 'foo':
          }
        END
      end

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(18)
      end

      it 'should single quote the resource title' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'condensed resources with an unquoted title' do
      let(:code) do
        <<-END
          file {
            'foo': ;
            bar: ;
          }
        END
      end

      let(:fixed) do
        <<-END
          file {
            'foo': ;
            'bar': ;
          }
        END
      end

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(13)
      end

      it 'should single quote the resource title' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
