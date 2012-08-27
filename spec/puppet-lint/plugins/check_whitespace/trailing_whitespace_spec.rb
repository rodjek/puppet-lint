require 'spec_helper'

describe 'trailing_whitespace' do
  describe 'line with trailing whitespace' do
    let(:code) { "foo " }

    its(:problems) {
      should have_problem({
        :kind       => :error,
        :message    => 'trailing whitespace found',
        :linenumber => 1,
        :column     => 4,
      })
    }
  end
end
