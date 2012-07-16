require 'spec_helper'

describe PuppetLint::Plugins::CheckVariables do
  subject do
    klass = described_class.new
    fileinfo = {}
    fileinfo[:fullpath] = defined?(fullpath).nil? ? '' : fullpath
    klass.run(fileinfo, code)
    klass
  end

  describe 'a variable containing a dash' do
    let(:code) { '$foo-bar' }

    its(:problems) { should have_problem({
      :kind       => :warning,
      :message    => 'variable contains a dash',
      :linenumber => 1,
      :column     => 1,
    }) }
  end

  describe 'variable containing a dash' do
    let(:code) { '" $foo-bar"' }

    its(:problems) { should have_problem({
      :kind       => :warning,
      :message    => 'variable contains a dash',
      :linenumber => 1,
      :column     => 3,
    }) }
  end
end
