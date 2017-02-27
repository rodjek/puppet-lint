require 'spec_helper'

describe 'code_on_top_scope' do
  describe 'comments outside class block' do
    let(:code) { "
      # Baz
      class foo:bar {
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'new lines outside of class-define block' do
    let(:code) { "

      class foo:bar {
      }

      "
    }

    its(:problems) { should be_empty }
  end

  describe 'code outside class block' do
    let(:code) { "
      include('something')

      # Baz
      class foo:bar {
      }

      define whatever {
      }"
    }

    its(:problems) {
      should contain_warning("code outside of class or define block - include")
      should have(4).problems
    }
  end
end
