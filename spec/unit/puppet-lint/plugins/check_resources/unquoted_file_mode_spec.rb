require 'spec_helper'

describe 'unquoted_file_mode' do
  let(:msg) { 'unquoted file mode' }

  context 'with fix disabled' do
    context '4 digit unquoted file mode' do
      let(:code) { "file { 'foo': mode => 0777 }" }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(23)
      end
    end

    context '4 digit unquoted file mode' do
      let(:code) { "concat { 'foo': mode => 0777 }" }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(25)
      end
    end

    context 'file mode from a function rvalue' do
      let(:code) { "file { 'foo': mode => lookup('bar'), }" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'multi body file bad modes selector' do
      let(:code) do
        <<-END
          file {
            '/tmp/foo1':
              ensure => $foo ? { default => absent },
              mode => 644;
            '/tmp/foo2':
              mode => 644;
            '/tmp/foo3':
              mode => 644;
          }
        END
      end

      it 'detects 3 problems' do
        expect(problems).to have(3).problems
      end

      it 'creates three warnings' do
        expect(problems).to contain_warning(sprintf(msg)).on_line(4).in_column(23)
        expect(problems).to contain_warning(sprintf(msg)).on_line(6).in_column(23)
        expect(problems).to contain_warning(sprintf(msg)).on_line(8).in_column(23)
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

    context '4 digit unquoted file mode w/fix' do
      let(:code) { "file { 'foo': mode => 0777 }" }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(23)
      end

      it 'single quotes the file mode' do
        expect(manifest).to eq("file { 'foo': mode => '0777' }")
      end
    end

    context '4 digit unquoted file mode w/fix' do
      let(:code) { "concat { 'foo': mode => 0777 }" }

      it 'only detects a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(25)
      end

      it 'single quotes the file mode' do
        expect(manifest).to eq("concat { 'foo': mode => '0777' }")
      end
    end

    context 'file mode from a function rvalue' do
      let(:code) { "file { 'foo': mode => lookup('bar'), }" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'does not change the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'multi body file bad modes selector' do
      let(:code) do
        <<-END
          file {
            '/tmp/foo1':
              ensure => $foo ? { default => absent },
              mode => 644;
            '/tmp/foo2':
              mode => 644;
            '/tmp/foo3':
              mode => 644;
          }
        END
      end

      let(:fixed) do
        <<-END
          file {
            '/tmp/foo1':
              ensure => $foo ? { default => absent },
              mode => '644';
            '/tmp/foo2':
              mode => '644';
            '/tmp/foo3':
              mode => '644';
          }
        END
      end

      it 'detects 3 problems' do
        expect(problems).to have(3).problems
      end

      it 'fixes 3 problems' do
        expect(problems).to contain_fixed(msg).on_line(4).in_column(23)
        expect(problems).to contain_fixed(msg).on_line(6).in_column(23)
        expect(problems).to contain_fixed(msg).on_line(8).in_column(23)
      end

      it 'quotes the file modes' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
