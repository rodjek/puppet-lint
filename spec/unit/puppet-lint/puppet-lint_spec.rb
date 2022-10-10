# rubocop: disable Naming/FileName

require 'spec_helper'

describe PuppetLint do
  subject(:linter) { described_class.new }

  it 'accepts manifests as a string' do
    linter.code = 'class foo { }'
    expect(linter.code).not_to be_nil
  end

  it 'returns empty manifest when empty one given as the input' do
    linter.code = ''
    linter.run
    expect(linter.manifest).to eq('')
  end
end
