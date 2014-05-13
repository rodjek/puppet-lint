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
end
