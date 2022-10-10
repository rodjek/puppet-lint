require 'spec_helper'

describe PuppetLint::Configuration do
  subject(:config) { described_class.new }

  it 'creates check methods on the fly' do
    klass = Class.new
    config.add_check('foo', klass)

    expect(config).to respond_to(:foo_enabled?)
    expect(config).not_to respond_to(:bar_enabled?)
    expect(config).to respond_to(:enable_foo)
    expect(config).to respond_to(:disable_foo)

    config.disable_foo
    expect(config.settings['foo_disabled']).to be_truthy
    expect(config.foo_enabled?).to be_falsey

    config.enable_foo
    expect(config.settings['foo_disabled']).to be_falsey
    expect(config.foo_enabled?).to be_truthy
  end

  it 'knows what checks have been added' do
    klass = Class.new
    config.add_check('foo', klass)
    expect(config.checks).to include('foo')
  end

  it 'responds nil to unknown config options' do
    expect(config.foobarbaz).to be_nil
  end

  it 'is able to explicitly add options' do
    config.add_option('bar')

    expect(config.bar).to be_nil

    config.bar = 'aoeui'
    expect(config.bar).to eq('aoeui')
  end

  it 'is able to add options on the fly' do
    expect(config.test_option).to eq(nil)

    config.test_option = 'test'

    expect(config.test_option).to eq('test')
  end

  it 'is able to set sane defaults' do
    override_env do
      ENV.delete('GITHUB_ACTION')
      config.defaults
    end

    expect(config.settings).to eq(
      'with_filename'    => false,
      'fail_on_warnings' => false,
      'error_level'      => :all,
      'log_format'       => '',
      'sarif'            => false,
      'with_context'     => false,
      'fix'              => false,
      'github_actions'   => false,
      'show_ignored'     => false,
      'json'             => false,
      'ignore_paths'     => ['vendor/**/*.pp'],
    )
  end

  it 'detects github actions' do
    override_env do
      ENV['GITHUB_ACTION'] = 'action'
      config.defaults
    end

    expect(config.settings['github_actions']).to be(true)
  end

  def override_env
    old_env = ENV.to_h
    yield
  ensure
    ENV.clear
    ENV.update(old_env)
  end
end
