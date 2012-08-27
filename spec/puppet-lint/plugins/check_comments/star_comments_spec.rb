require 'spec_helper'

describe 'star_comments' do
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
