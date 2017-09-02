require 'spec_helper'

describe 'quoted_booleans', :type => :lint do
  let(:msg) { 'quoted boolean value found' }

  context 'with a single line ignore' do
    let(:code) do
      <<-END
        'true'
        'true' # lint:ignore:quoted_booleans
        'false'
      END
    end

    it 'should detect three problems' do
      expect(problems).to have(3).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(9)
      expect(problems).to contain_warning(msg).on_line(3).in_column(9)
    end

    it 'should have one ignored problem' do
      expect(problems).to contain_ignored(msg).on_line(2).in_column(9)
    end
  end

  context 'with a single line ignore and a reason' do
    let(:code) do
      <<-END
        'true'
        'true' # lint:ignore:quoted_booleans some good reason
        'false'
      END
    end

    it 'should detect three problems' do
      expect(problems).to have(3).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(9)
      expect(problems).to contain_warning(msg).on_line(3).in_column(9)
    end

    it 'should have one ignored problem with a reason' do
      expect(problems).to contain_ignored(msg).on_line(2).in_column(9).with_reason('some good reason')
    end
  end

  context 'with a block ignore' do
    let(:code) do
      <<-END
        'true'
        # lint:ignore:quoted_booleans
        'false'
        'true'
        # lint:endignore
        'true'
      END
    end

    it 'should detect four problems' do
      expect(problems).to have(4).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(9)
      expect(problems).to contain_warning(msg).on_line(6).in_column(9)
    end

    it 'should have two ignored problems' do
      expect(problems).to contain_ignored(msg).on_line(3).in_column(9)
      expect(problems).to contain_ignored(msg).on_line(4).in_column(9)
    end
  end

  context 'with a block ignore and a reason' do
    let(:code) do
      <<-END
        'true'
        # lint:ignore:quoted_booleans another reason
        'false'
        'true'
        # lint:endignore
        'true'
      END
    end

    it 'should detect four problems' do
      expect(problems).to have(4).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(9)
      expect(problems).to contain_warning(msg).on_line(6).in_column(9)
    end

    it 'should have two ignored problems with a reason' do
      expect(problems).to contain_ignored(msg).on_line(3).in_column(9).with_reason('another reason')
      expect(problems).to contain_ignored(msg).on_line(4).in_column(9).with_reason('another reason')
    end
  end

  context 'disable multiple checks on a line with a reason' do
    let(:code) { '"true" # lint:ignore:quoted_booleans lint:ignore:double_quoted_string a reason' }

    it 'should detect 1 problems' do
      expect(problems).to have(1).problems
    end

    it 'should have one ignored problems' do
      expect(problems).to contain_ignored(msg).on_line(1).in_column(1).with_reason('a reason')
    end
  end

  context 'disable multiple checks in a block' do
    let(:code) do
      <<-END

        # lint:ignore:double_quoted_string lint:ignore:quoted_booleans lint:ignore:arrow_alignment
        foo { "bar":
          test => 'true',
          other_test => 'false',
        }
        # lint:endignore
      END
    end

    it 'should detect 2 problems' do
      expect(problems).to have(2).problems
    end

    it 'should ignore both problems' do
      expect(problems).to contain_ignored(msg).on_line(4).in_column(19).with_reason('')
      expect(problems).to contain_ignored(msg).on_line(5).in_column(25).with_reason('')
    end
  end
end
