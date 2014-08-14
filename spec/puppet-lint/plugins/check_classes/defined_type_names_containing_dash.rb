require 'spec_helper'

describe 'defined_type_names_containing_dash' do
  let(:class_msg) { 'class name containing a dash' }
  let(:define_msg) { 'defined type name containing a dash' }

  context 'define named foo-bar' do
    let(:code) { 'define foo::foo-bar { }' }
    let(:path) { 'foo/manifests/foo-bar.pp' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(define_msg).on_line(1).in_column(8)
    end
  end
end
