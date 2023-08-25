require 'spec_helper'

describe 'check_unsafe_interpolations' do
  let(:msg) { "unsafe interpolation of variable 'foo' in exec command" }

  context 'with fix disabled' do
    context 'exec with unsafe interpolation in command' do
      let(:code) do
        <<-PUPPET
        class foo {

          exec { 'bar':
            command => "echo ${foo}",
          }

        }
        PUPPET
      end

      it 'detects an unsafe exec command argument' do
        expect(problems).to have(1).problems
      end

      it 'creates one warning' do
        expect(problems).to contain_warning(msg)
      end
    end

    context 'exec with multiple unsafe interpolations in command' do
      let(:code) do
        <<-PUPPET
        class foo {

          exec { 'bar':
            command => "echo ${foo} ${bar}",
          }

        }
        PUPPET
      end

      it 'detects multiple unsafe exec command arguments' do
        expect(problems).to have(2).problems
      end

      it 'creates two warnings' do
        expect(problems).to contain_warning(msg)
        expect(problems).to contain_warning(msg)
      end
    end

    context 'code that uses title with unsafe string as command' do
      let(:code) do
        <<-PUPPET
        class foo {

          exec { "echo ${foo}": }

        }
        PUPPET
      end

      it 'detects one problem' do
        expect(problems).to have(1).problems
      end

      it 'creates one warning' do
        expect(problems).to contain_warning(msg)
      end
    end

    context 'exec with a safe string in command' do
      let(:code) do
        <<-PUPPET
        class foo {

          exec { 'bar':
            command => "echo foo",
          }

        }
        PUPPET
      end

      it 'detects zero problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'exec that has an array of args in command' do
      let(:code) do
        <<-PUPPET
        class foo {

          exec { 'bar':
            command => ['echo', $foo],
          }
        }
        PUPPET
      end

      it 'detects zero problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'exec that has an array of args in command' do
      let(:code) do
        <<-PUPPET
        class foo {

          exec { ["foo", "bar", "baz"]:
            command => echo qux,
          }
        }
        PUPPET
      end

      it 'detects zero problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'file resource' do
      let(:code) do
        <<-PUPPET
        class foo {
          file { '/etc/bar':
            ensure  => file,
            backup  => false,
            content => $baz,
          }
        }
        PUPPET
      end

      it 'detects zero problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'file resource and an exec with unsafe interpolation in command' do
      let(:code) do
        <<-PUPPET
        class foo {
          file { '/etc/bar':
            ensure  => file,
            backup  => false,
            content => $baz,
          }

          exec { 'qux':
            command => "echo ${foo}",
          }
        }
        PUPPET
      end

      it 'detects one problem' do
        expect(problems).to have(1).problems
      end
    end

    context 'case statement and an exec' do
      let(:code) do
        <<-PUPPET
        class foo {
          case bar {
            baz : {
              echo qux
            }
          }

          exec { 'foo':
            command => "echo bar",
          }
        }
        PUPPET
      end

      it 'detects zero problems' do
        expect(problems).to have(0).problems
      end
    end
  end
end
