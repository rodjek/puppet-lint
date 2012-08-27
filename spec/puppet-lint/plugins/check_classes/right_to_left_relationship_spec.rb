require 'spec_helper'

describe 'right_to_left_relationship' do
  describe 'chain 2 resources left to right' do
    let(:code) { "Class[foo] -> Class[bar]" }

    its(:problems) { should be_empty }
  end

  describe 'chain 2 resources right to left' do
    let(:code) { "Class[foo] <- Class[bar]" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => "right-to-left (<-) relationship",
        :linenumber => 1,
        :column     => 12,
      })
      should_not have_problem :kind => :error
    }
  end
end
