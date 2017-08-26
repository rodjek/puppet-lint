require 'spec_helper'

describe 'code_on_top_scope' do
  describe 'comments outside class block' do
    let(:code) do
      <<-END
        # Baz
        class foo:bar {
        }
      END
    end

    its(:problems) { should be_empty }
  end

  describe 'new lines outside of class-define block' do
    let(:code) do
      <<-END

        class foo:bar {
        }

      END
    end

    its(:problems) { should be_empty }
  end

  describe 'code outside class block' do
    let(:code) do
      <<-END
        include('something')

        # Baz
        class foo:bar {
        }

        define whatever {
        }
      END
    end

    its(:problems) do
      should contain_warning('code outside of class or define block - include')
      should have(4).problems
    end
  end
end
