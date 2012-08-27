require 'spec_helper'

describe 'slash_comments' do
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
end
