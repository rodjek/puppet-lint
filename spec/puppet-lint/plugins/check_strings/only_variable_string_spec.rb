require 'spec_helper'

describe 'only_variable_string' do
  describe 'string containing only a variable' do
    let(:code) { '"${foo}"' }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => 'string containing only a variable',
        :linenumber => 1,
        :column     => 3,
      })
    }
  end
end
