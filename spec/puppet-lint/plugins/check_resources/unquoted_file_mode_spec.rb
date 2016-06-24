require 'spec_helper'

describe 'unquoted_file_mode' do
  let(:msg) { 'unquoted file mode' }

  context 'with fix disabled' do
    context '4 digit unquoted file mode' do
      let(:code) { "file { 'foo': mode => 0777 }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(23)
      end
    end

    context '4 digit unquoted file mode' do
      let(:code) { "concat { 'foo': mode => 0777 }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(25)
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

    context '4 digit unquoted file mode w/fix' do
      let(:code) { "file { 'foo': mode => 0777 }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(23)
      end

      it 'should single quote the file mode' do
        expect(manifest).to eq("file { 'foo': mode => '0777' }")
      end
    end

    context '4 digit unquoted file mode w/fix' do
      let(:code) { "concat { 'foo': mode => 0777 }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(25)
      end

      it 'should single quote the file mode' do
        expect(manifest).to eq("concat { 'foo': mode => '0777' }")
      end
    end
  end
end
