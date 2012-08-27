require 'spec_helper'

describe '2sp_soft_tabs' do
  describe 'line indented by 3 spaces' do
    let(:code) { "
      file { 'foo':
         foo => bar,
      }"
    }

    its(:problems) {
      should have_problem({
        :kind       => :error,
        :message    => 'two-space soft tabs not used',
        :linenumber => 3,
        :column     => 1,
      })
    }
  end
end
