require 'spec_helper'

describe 'names_containing_uppercase' do
  
  context 'defined type named FooBar' do
    let(:code) { 'define FooBar { }' }
    let(:path) { 'foobar/manifests/init.pp' }
    let(:class_msg) { "defined type 'FooBar' contains illegal uppercase" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(class_msg).on_line(1).in_column(8)
    end
  end

  context 'class named FooBar' do
    let(:code) { 'class FooBar { }' }
    let(:path) { 'foobar/manifests/init.pp' }
    let(:class_msg) { "class 'FooBar' contains illegal uppercase" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(class_msg).on_line(1).in_column(7)
    end
  end

  context 'class named Foo::BarFoo' do
    let(:code) { 'class Foo::BarFoo { }' }
    let(:path) { 'foo/manifests/barfoo.pp' }
    let(:class_msg) { "class 'Foo::BarFoo' contains illegal uppercase" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(class_msg).on_line(1).in_column(7)
    end

    context 'check fix -' do
      before do
        PuppetLint.configuration.fix = true
      end
      
      after do
        PuppetLint.configuration.fix = false
      end
      
      let(:fixed) { code.downcase }
      
      it 'should create an error' do
        expect(problems).to contain_fixed(class_msg).on_line(1).in_column(7)
      end
      
      it 'should downcase the class name' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end
