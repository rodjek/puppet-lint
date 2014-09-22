require 'spec_helper'

describe 'quoted_booleans', :type => :lint do
  let(:msg) { 'quoted boolean value found' }

  context 'with a single line ignore' do
    let(:code) { "
      'true'
      'true' # lint:ignore:quoted_booleans
      'false'
    " }

    it 'should detect three problems' do
      expect(problems).to have(3).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(7)
      expect(problems).to contain_warning(msg).on_line(4).in_column(7)
    end

    it 'should have one ignored problem' do
      expect(problems).to contain_ignored(msg).on_line(3).in_column(7)
    end
  end

  context 'with a single line ignore and a reason' do
    let(:code) { "
      'true'
      'true' # lint:ignore:quoted_booleans some good reason
      'false'
    " }

    it 'should detect three problems' do
      expect(problems).to have(3).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(7)
      expect(problems).to contain_warning(msg).on_line(4).in_column(7)
    end

    it 'should have one ignored problem with a reason' do
      expect(problems).to contain_ignored(msg).on_line(3).in_column(7).with_reason('some good reason')
    end
  end

  context 'with a block ignore' do
    let(:code) { "
      'true'
      # lint:ignore:quoted_booleans
      'false'
      'true'
      # lint:endignore
      'true'
    " }

    it 'should detect four problems' do
      expect(problems).to have(4).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(7)
      expect(problems).to contain_warning(msg).on_line(7).in_column(7)
    end

    it 'should have two ignored problems' do
      expect(problems).to contain_ignored(msg).on_line(4).in_column(7)
      expect(problems).to contain_ignored(msg).on_line(5).in_column(7)
    end
  end

  context 'with a block ignore and a reason' do
    let(:code) { "
      'true'
      # lint:ignore:quoted_booleans another reason
      'false'
      'true'
      # lint:endignore
      'true'
    " }

    it 'should detect four problems' do
      expect(problems).to have(4).problems
    end

    it 'should have two warnings' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(7)
      expect(problems).to contain_warning(msg).on_line(7).in_column(7)
    end

    it 'should have two ignored problems with a reason' do
      expect(problems).to contain_ignored(msg).on_line(4).in_column(7).with_reason('another reason')
      expect(problems).to contain_ignored(msg).on_line(5).in_column(7).with_reason('another reason')
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
end
