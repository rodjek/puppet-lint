require 'spec_helper'

describe 'hard_tabs' do
  describe 'hard tabs indents' do
    let(:code) { "\tfoo => bar," }

    its(:problems) {
      should have_problem({
        :kind       => :error,
        :message    => 'tab character found',
        :linenumber => 1,
        :column     => 1,
      })
    }
  end
end
