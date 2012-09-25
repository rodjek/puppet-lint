require 'spec_helper'

describe PuppetLint::Configuration do
  subject { PuppetLint::Configuration.new }

  it 'should create check methods on the fly' do
    method = Proc.new { true }
    subject.add_check('foo', &method)

    subject.should respond_to(:foo_enabled?)
    subject.should_not respond_to(:bar_enabled?)
    subject.should respond_to(:enable_foo)
    subject.should respond_to(:disable_foo)

    subject.disable_foo
    subject.settings['foo_disabled'].should == true
    subject.foo_enabled?.should == false

    subject.enable_foo
    subject.settings['foo_disabled'].should == false
    subject.foo_enabled?.should == true
  end

  it 'should know what checks have been added' do
    method = Proc.new { true }
    subject.add_check('foo', &method)
    subject.checks.should include('foo')
  end

  it 'should respond nil to unknown config options' do
    subject.foobarbaz.should == nil
  end

  it 'should create options on the fly' do
    subject.add_option('bar')

    subject.bar.should == nil

    subject.bar = 'aoeui'
    subject.bar.should == 'aoeui'
  end

  it 'should be able to set sane defaults' do
    subject.defaults

    subject.settings.should == {
      'with_filename' => false,
      'fail_on_warnings' => false,
      'error_level' => :all,
      'log_format' => '',
      'with_context' => false,
    }
  end
end

