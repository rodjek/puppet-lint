# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'When executing puppet-lint' do
  let(:manifest_root) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'test', 'manifests') }

  context 'with no manifest provided' do
    it 'returns an exit code of 1 with no arguments' do
      result = puppet_lint
      expect(result[:exit_code]).to eq(1)
    end

    it 'returns an exit code of 0 when given a single flag' do
      result = puppet_lint(['--help'])
      expect(result[:exit_code]).to eq(0)
    end

    it 'returns the correct version number with the --version flag' do
      result = puppet_lint(['--version'])
      expect(result[:stdout]).to match(PuppetLint::VERSION)
    end
  end

  context 'with a manifest provided' do
    it 'returns one error when there is one problem' do
      result = puppet_lint([File.join(manifest_root, 'fail.pp')])
      expect(result[:stdout]).to have_errors(1)
    end

    it 'returns zero errors when there is an ignore comment present' do
      result = puppet_lint([File.join(manifest_root, 'ignore.pp')])
      expect(result[:stdout]).to have_errors(0)
    end

    it 'returns one warning when there is one problem' do
      result = puppet_lint([File.join(manifest_root, 'warning.pp')])
      expect(result[:stdout]).to have_warnings(1)
    end

    it 'contains two warnings when there are two problems' do
      result = puppet_lint([File.join(manifest_root, 'two_warnings.pp')])
      expect(result[:stdout]).to have_warnings(2)
    end
  end
end
