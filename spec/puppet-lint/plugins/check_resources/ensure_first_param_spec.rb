require 'spec_helper'

describe 'ensure_first_param' do
  let(:msg) { "ensure found on line but it's not the first attribute" }

  context 'with fix disabled' do
    context 'ensure as only attr in a single line resource' do
      let(:code) { "file { 'foo': ensure => present }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'ensure as only attr in a multi line resource' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => present,
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'ensure as second attr in a multi line resource' do
      let(:code) do
        <<-END
          file { 'foo':
            mode   => '0000',
            ensure => present,
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

    context 'ensure as first attr in a multi line resource' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => present,
            mode   => '0000',
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'ensure as a hash key in classes does not need to be first' do
      let(:code) do
        <<-END
          class thing {
            class { 'thang':
              stuff => {
                'stuffing' => {
                  ensure => 'present',
                  blah   => 'bleah',
                }
              },
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

    context 'ensure as only attr in a single line resource' do
      let(:code) { "file { 'foo': ensure => present }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'ensure as only attr in a multi line resource' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => present,
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'ensure as second attr in a multi line resource' do
      let(:code) do
        <<-END
          file { 'foo':
            mode   => '0000',
            ensure => present,
          }
        END
      end

      let(:fixed) do
        <<-END
          file { 'foo':
            ensure => present,
            mode   => '0000',
          }
        END
      end

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(13)
      end

      it 'should make ensure the first attr' do
        expect(manifest).to eq(fixed)
      end
    end

    context 'ensure as first attr in a multi line resource' do
      let(:code) do
        <<-END
          file { 'foo':
            ensure => present,
            mode   => '0000',
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'ensure as a hash key in classes does not need to be first' do
      let(:code) do
        <<-END
          class thing {
            class { 'thang':
              stuff => {
                'stuffing' => {
                  ensure => 'present',
                  blah   => 'bleah',
                }
              },
            }
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'ensure is a selector' do
      let(:code) do
        <<-END
          file { 'foo':
            mode   => '0640',
            ensure => $::operatingsystem ? {
              'redhat' => absent,
              default  => $::phase_of_the_moon ? {
                'full'  => absent,
                default => present,
              },
            },
          }
        END
      end

      let(:fixed) do
        <<-END
          file { 'foo':
            ensure => $::operatingsystem ? {
              'redhat' => absent,
              default  => $::phase_of_the_moon ? {
                'full'  => absent,
                default => present,
              },
            },
            mode   => '0640',
          }
        END
      end

      it 'should detect a problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the problem' do
        expect(problems).to contain_fixed(msg).on_line(3).in_column(13)
      end

      it 'should move the whole ensure parameter to the top' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
