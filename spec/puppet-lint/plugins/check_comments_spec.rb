require 'spec_helper'

describe PuppetLint::Plugins::CheckComments do
  subject do
    klass = described_class.new
    fileinfo = {}
    fileinfo[:fullpath] = defined?(fullpath).nil? ? '' : fullpath
    klass.run(fileinfo, code)
    klass
  end

  describe 'slash comments' do
    let(:code) { "// foo" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => '// comment found',
        :linenumber => 1,
        :column     => 1,
      })
    end
  end

  describe 'slash asterisk comment' do
    let(:code) { "
      /* foo
      */
    "}

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => '/* */ comment found',
        :linenumber => 2,
        :column     => 7,
      })
    end
  end
end
