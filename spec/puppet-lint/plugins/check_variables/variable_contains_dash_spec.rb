require 'spec_helper'

describe 'variable_contains_dash' do
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
