require 'spec_helper'

describe 'class_names_containing_dash' do
  let(:class_msg) { 'class name containing a dash' }
  let(:define_msg) { 'defined type name containing a dash' }

  context 'module named foo-bar' do
    let(:code) { 'class foo-bar { }' }
    let(:path) { 'foo-bar/manifests/init.pp' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(1).in_column(7)
    end
  end

  context 'class named bar-foo' do
    let(:code) { 'class foo::bar-foo { }' }
    let(:path) { 'foo/manifests/bar-foo.pp' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(1).in_column(7)
    end
  end
end
