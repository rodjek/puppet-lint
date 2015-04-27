require 'spec_helper'

describe PuppetLint::Configuration do
  subject { PuppetLint::Configuration.new }

  it 'should create check methods on the fly' do
    klass = Class.new
    subject.add_check('foo', klass)

    expect(subject).to respond_to(:foo_enabled?)
    expect(subject).to_not respond_to(:bar_enabled?)
    expect(subject).to respond_to(:enable_foo)
    expect(subject).to respond_to(:disable_foo)

    subject.disable_foo
    expect(subject.settings['foo_disabled']).to be_truthy
    expect(subject.foo_enabled?).to be_falsey

    subject.enable_foo
    expect(subject.settings['foo_disabled']).to be_falsey
    expect(subject.foo_enabled?).to be_truthy
  end

  it 'should know what checks have been added' do
    klass = Class.new
    subject.add_check('foo', klass)
    expect(subject.checks).to include('foo')
  end

  it 'should respond nil to unknown config options' do
    expect(subject.foobarbaz).to be_nil
  end

  it 'should create options on the fly' do
    subject.add_option('bar')

    expect(subject.bar).to be_nil

    subject.bar = 'aoeui'
    expect(subject.bar).to eq('aoeui')
  end

  it 'should be able to set sane defaults' do
    subject.defaults

    expect(subject.settings).to eq({
      'with_filename' => false,
      'fail_on_warnings' => false,
      'error_level' => :all,
      'log_format' => '',
      'with_context' => false,
      'fix' => false,
      'show_ignored' => false,
      'json' => false,
    })
  end
end
