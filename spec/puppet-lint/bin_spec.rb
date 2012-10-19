require 'spec_helper'
require 'rspec/mocks'
require 'optparse'

class CommandRun
  attr_accessor :stdout, :stderr, :exitstatus

  def initialize(args)
    out = StringIO.new
    err = StringIO.new

    $stdout = out
    $stderr = err

    PuppetLint.configuration.defaults
    @exitstatus = PuppetLint::Bin.new(args).run
    PuppetLint.configuration.defaults

    @stdout = out.string.strip
    @stderr = err.string.strip

    $stdout = STDOUT
    $stderr = STDERR
  end
end

describe PuppetLint::Bin do
  subject do
    if args.is_a? Array
      sane_args = args
    else
      sane_args = [args]
    end

    CommandRun.new(sane_args)
  end

  context 'when running normally' do
    let(:args) { 'spec/fixtures/test/manifests/init.pp' }

    its(:exitstatus) { should == 0 }
  end

  context 'when running without arguments' do
    let(:args) { [] }

    its(:exitstatus) { should == 1 }
  end

  context 'when asked to display version' do
    let(:args) { '--version' }

    its(:exitstatus) { should == 0 }
    its(:stdout) { should == "Puppet-lint #{PuppetLint::VERSION}" }
  end

  context 'when passed multiple files' do
    let(:args) { [
      'spec/fixtures/test/manifests/warning.pp',
      'spec/fixtures/test/manifests/fail.pp',
    ] }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should == [
      'WARNING: optional parameter listed before required parameter on line 2',
      'ERROR: test::foo not in autoload module layout on line 2',
    ].join("\n") }
  end

  context 'when passed a malformed file' do
    let(:args) { 'spec/fixtures/test/manifests/malformed.pp' }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should == 'ERROR: Syntax error (try running `puppet parser validate <file>`) on line 1' }
  end

  context 'when limited to errors only' do
    let(:args) { [
      '--error-level', 'error',
      'spec/fixtures/test/manifests/warning.pp',
      'spec/fixtures/test/manifests/fail.pp',
    ] }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should match(/^ERROR/) }
  end

  context 'when limited to errors only' do
    let(:args) { [
      '--error-level', 'warning',
      'spec/fixtures/test/manifests/warning.pp',
      'spec/fixtures/test/manifests/fail.pp',
    ] }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should match(/^WARNING/) }
  end

  context 'when asked to display filenames ' do
    let(:args) { ['--with-filename', 'spec/fixtures/test/manifests/fail.pp'] }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should match(%r{^spec/fixtures/test/manifests/fail\.pp -}) }
  end

  context 'when not asked to fail on warnings' do
    let(:args) { ['spec/fixtures/test/manifests/warning.pp'] }

    its(:exitstatus) { should == 0 }
    its(:stdout) { should match(/optional parameter/) }
  end

  context 'when asked to provide context to problems' do
    let(:args) { [
      '--with-context',
      'spec/fixtures/test/manifests/warning.pp',
    ] }

    its(:exitstatus) { should == 0 }
    its(:stdout) { should == [
      'WARNING: optional parameter listed before required parameter on line 2',
      '',
      "  define test::warning($foo='bar', $baz) { }",
      '                                   ^',
    ].join("\n")
    }
  end

  context 'when asked to fail on warnings' do
    let(:args) { [
      '--fail-on-warnings',
      'spec/fixtures/test/manifests/warning.pp',
    ] }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should match(/optional parameter/) }
  end

  context 'when used with an invalid option' do
    let(:args) { '--foo-bar-baz' }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should match(/invalid option/) }
  end

  context 'when passed a file that does not exist' do
    let(:args) { 'spec/fixtures/test/manifests/enoent.pp' }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should match(/specified file does not exist/) }
  end

  context 'when passed a directory' do
    let(:args) { 'spec/fixtures/' }

    its(:exitstatus) { should == 1 }
    its(:stdout) { should match(/^ERROR/) }
  end

  context 'when disabling a check' do
    let(:args) { [
      '--no-autoloader_layout',
      'spec/fixtures/test/manifests/fail.pp'
    ] }

    its(:exitstatus) { should == 0 }
    its(:stdout) { should == "" }
  end

  context 'when changing the log format' do
    context 'to print %{filename}' do
      let(:args) { [
        '--log-format', '%{filename}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) { should == 'fail.pp' }
    end

    context 'to print %{path}' do
      let(:args) { [
        '--log-format', '%{path}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) { should == 'spec/fixtures/test/manifests/fail.pp' }
    end

    context 'to print %{fullpath}' do
      let(:args) { [
        '--log-format', '%{fullpath}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) {
        should match(%r{^/.+/spec/fixtures/test/manifests/fail\.pp$})
      }
    end

    context 'to print %{linenumber}' do
      let(:args) { [
        '--log-format', '%{linenumber}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) { should == '2' }
    end

    context 'to print %{kind}' do
      let(:args) { [
        '--log-format', '%{kind}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) { should == 'error' }
    end

    context 'to print %{KIND}' do
      let(:args) { [
        '--log-format', '%{KIND}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) { should == 'ERROR' }
    end

    context 'to print %{check}' do
      let(:args) { [
        '--log-format', '%{check}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) { should == 'autoloader_layout' }
    end

    context 'to print %{message}' do
      let(:args) { [
        '--log-format', '%{message}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { should == 1 }
      its(:stdout) { should == 'test::foo not in autoload module layout' }
    end

    context 'when loading options from a file' do
      let(:args) { 'spec/fixtures/test/manifests/fail.pp' }

      it 'should have ~/.puppet-lintrc as depreciated' do
        OptionParser.any_instance.stub(:load).
          with(File.expand_path('~/.puppet-lintrc')).and_return(true)
        OptionParser.any_instance.stub(:load).
          with(File.expand_path('~/.puppet-lint.rc')).and_return(false)
        OptionParser.any_instance.stub(:load).
          with('.puppet-lintrc').and_return(false)
        OptionParser.any_instance.stub(:load).
          with('.puppet-lint.rc').and_return(false)
        OptionParser.any_instance.stub(:load).
          with('/etc/puppet-lint.rc').and_return(false)

        msg = 'Depreciated: Found ~/.puppet-lintrc instead of ~/.puppet-lint.rc'
        subject.stderr.should == msg
      end

      it 'should have .puppet-lintrc as depreciated' do
        OptionParser.any_instance.stub(:load).
          with(File.expand_path('~/.puppet-lintrc')).and_return(false)
        OptionParser.any_instance.stub(:load).
          with(File.expand_path('~/.puppet-lint.rc')).and_return(false)
        OptionParser.any_instance.stub(:load).
          with('.puppet-lintrc').and_return(true)
        OptionParser.any_instance.stub(:load).
          with('.puppet-lint.rc').and_return(false)
        OptionParser.any_instance.stub(:load).
          with('/etc/puppet-lint.rc').and_return(false)

        msg = 'Depreciated: Read .puppet-lintrc instead of .puppet-lint.rc'
        subject.stderr.should == msg
      end
    end
  end
end
