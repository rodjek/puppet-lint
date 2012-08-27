require 'spec_helper'

describe 'variables_not_enclosed' do
  describe 'variable not enclosed in {}' do
    let(:code) { '" $gronk"' }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => 'variable not enclosed in {}',
        :linenumber => 1,
        :column     => 3,
      })
    }
  end

  describe 'variable not enclosed in {} after many tokens' do
    let(:code) { ("'groovy'\n" * 20) + '" $gronk"' }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => 'variable not enclosed in {}',
        :linenumber => 21,
        :column     => 3,
      })
    }
  end
end
