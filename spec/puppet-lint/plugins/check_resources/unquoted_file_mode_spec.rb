require 'spec_helper'

describe 'unquoted_file_mode' do
  describe '4 digit unquoted file mode' do
    let(:code) { "file { 'foo': mode => 0777 }" }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "unquoted file mode"
    }
  end
end
