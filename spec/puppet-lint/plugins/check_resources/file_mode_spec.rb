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
  end
end
