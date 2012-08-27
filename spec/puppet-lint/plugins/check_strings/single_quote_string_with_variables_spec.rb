require 'spec_helper'

describe 'single_quote_string_with_variables' do
  describe 'multiple strings in a line' do
    let(:code) { "\"aoeu\" '${foo}'" }

    its(:problems) {
      should have_problem({
        :kind       => :error,
        :message    => 'single quoted string containing a variable found',
        :linenumber => 1,
        :column     => 8,
      })
    }
  end
end
