require 'spec_helper'

describe 'quoted_booleans' do
  let(:msg) { 'quoted boolean value found' }

  context 'with fix disabled' do
    context 'quoted false' do
      let(:code) { "class { 'foo': boolFlag => 'false' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(28)
      end
    end

    context 'quoted true' do
      let(:code) { "class { 'foo': boolFlag => 'true' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(28)
      end
    end

    context 'double quoted true' do
      let(:code) { "class { 'foo': boolFlag => \"true\" }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(28)
      end
    end

    context 'double quoted false' do
      let(:code) { "class { 'foo': boolFlag => \"false\" }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(28)
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

    context 'quoted false' do
      let(:code) { "class { 'foo': boolFlag => 'false' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(28)
      end

      it 'should unquote the boolean' do
        expect(manifest).to eq("class { 'foo': boolFlag => false }")
      end
    end

    context 'quoted true' do
      let(:code) { "class { 'foo': boolFlag => 'true' }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(28)
      end

      it 'should unquote the boolean' do
        expect(manifest).to eq("class { 'foo': boolFlag => true }")
      end
    end

    context 'double quoted true' do
      let(:code) { "class { 'foo': boolFlag => \"true\" }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(28)
      end

      it 'should unquote the boolean' do
        expect(manifest).to eq("class { 'foo': boolFlag => true }")
      end
    end

    context 'double quoted false' do
      let(:code) { "class { 'foo': boolFlag => \"false\" }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(28)
      end

      it 'should unquote the boolean' do
        expect(manifest).to eq("class { 'foo': boolFlag => false }")
      end
    end
  end
end
