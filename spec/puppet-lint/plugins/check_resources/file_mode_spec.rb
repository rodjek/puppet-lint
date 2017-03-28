require 'spec_helper'

describe 'file_mode' do
  let(:msg) { 'mode should be represented as a 4 digit octal value or symbolic mode' }

  context 'with fix disabled' do
    context '3 digit file mode' do
      let(:code) { "file { 'foo': mode => '777' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(23)
      end
    end

    context '4 digit file mode' do
      let(:code) { "file { 'foo': mode => '0777' }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'file mode as a variable' do
      let(:code) { "file { 'foo': mode => $file_mode }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'symbolic file mode' do
      let(:code) { "file { 'foo': mode => 'u=rw,og=r' }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'file mode undef unquoted' do
      let(:code) { "file { 'foo': mode => undef }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'file mode undef quoted' do
      let(:code) { "file { 'foo': mode => 'undef' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(23)
      end
    end

    context 'mode as audit value' do
      let(:code) { "file { '/etc/passwd': audit => [ owner, mode ], }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context '3 digit concat mode' do
      let(:code) { "concat { 'foo': mode => '777' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(25)
      end
    end

    context '4 digit concat mode' do
      let(:code) { "concat { 'foo': mode => '0777' }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'concat mode as a variable' do
      let(:code) { "concat { 'foo': mode => $concat_mode }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'symbolic concat mode' do
      let(:code) { "concat { 'foo': mode => 'u=rw,og=r' }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'concat mode undef unquoted' do
      let(:code) { "concat { 'foo': mode => undef }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'concat mode undef quoted' do
      let(:code) { "concat { 'foo': mode => 'undef' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(25)
      end
    end

    context 'mode as audit value' do
      let(:code) { "concat { '/etc/passwd': audit => [ owner, mode ], }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'mode as a function return value' do
      let(:code) { "file { 'foo': mode => lookup('bar'), }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'multi body file bad modes selector' do
      let(:code) { "
        file {
          '/tmp/foo1':
            ensure => $foo ? { default => absent },
            mode => 644;
          '/tmp/foo2':
            mode => 644;
          '/tmp/foo3':
            mode => 644;
         }"
      }

      it 'should detect 3 problems' do
        expect(problems).to have(3).problems
      end

      it 'should create three warnings' do
        expect(problems).to contain_warning(sprintf(msg)).on_line(5).in_column(21)
        expect(problems).to contain_warning(sprintf(msg)).on_line(7).in_column(21)
        expect(problems).to contain_warning(sprintf(msg)).on_line(9).in_column(21)
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

    context '3 digit file mode' do
      let(:code) { "file { 'foo': mode => '777' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(23)
      end

      it 'should zero pad the file mode' do
        expect(manifest).to eq("file { 'foo': mode => '0777' }")
      end
    end

    context 'file mode undef quoted' do
      let(:code) { "file { 'foo': mode => 'undef' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(23)
      end

      it 'should not modify the original manifest' do
        expect(manifest).to eq(code)
      end
    end

    context '3 digit concat mode' do
      let(:code) { "concat { 'foo': mode => '777' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(25)
      end

      it 'should zero pad the concat mode' do
        expect(manifest).to eq("concat { 'foo': mode => '0777' }")
      end
    end

    context 'concat mode undef quoted' do
      let(:code) { "concat { 'foo': mode => 'undef' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(25)
      end

      it 'should not modify the original manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'mode as a function return value' do
      let(:code) { "file { 'foo': mode => lookup('bar'), }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'should not change the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'multi body file bad modes selector' do
      let(:code) { "
        file {
          '/tmp/foo1':
            ensure => $foo ? { default => absent },
            mode => 644;
          '/tmp/foo2':
            mode => 644;
          '/tmp/foo3':
            mode => 644;
         }"
      }

      let(:fixed) { "
        file {
          '/tmp/foo1':
            ensure => $foo ? { default => absent },
            mode => '0644';
          '/tmp/foo2':
            mode => '0644';
          '/tmp/foo3':
            mode => '0644';
         }"
      }

      it 'should detect 3 problems' do
        expect(problems).to have(3).problems
      end

      it 'should fix 3 problems' do
        expect(problems).to contain_fixed(msg).on_line(5).in_column(21)
        expect(problems).to contain_fixed(msg).on_line(7).in_column(21)
        expect(problems).to contain_fixed(msg).on_line(9).in_column(21)
      end

      it 'should zero pad the file modes and change them to strings' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
