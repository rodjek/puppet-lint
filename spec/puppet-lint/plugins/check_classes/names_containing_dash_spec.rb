require 'spec_helper'

describe 'names_containing_dash' do
  let(:class_msg) { 'class name containing a dash' }
  let(:define_msg) { 'defined type name containing a dash' }

  context 'module named foo-bar' do
    let(:code) { 'class foo-bar { }' }
    let(:path) { 'foo-bar/manifests/init.pp' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(class_msg).on_line(1).in_column(7)
    end
  end

  context 'define named foo-bar' do
    let(:code) { 'define foo::foo-bar { }' }
    let(:path) { 'foo/manifests/foo-bar.pp' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(define_msg).on_line(1).in_column(8)
    end
  end

  context 'class named bar-foo' do
    let(:code) { 'class foo::bar-foo { }' }
    let(:path) { 'foo/manifests/bar-foo.pp' }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(class_msg).on_line(1).in_column(7)
    end
  end

  context 'multiple classes' do
    let(:code) do '
       class foo::bar_foo { }
       class foo::baz-foo { }
      '
    end

    it 'should create an error' do
      expect(problems).to contain_error(class_msg).on_line(3).in_column(14)
    end
  end
end
