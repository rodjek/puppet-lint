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

    its(:exitstatus) { is_expected.to eq(0) }
  end

  context 'when running without arguments' do
    let(:args) { [] }

    its(:exitstatus) { is_expected.to eq(1) }
  end

  context 'when asked to display version' do
    let(:args) { '--version' }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to eq("puppet-lint #{PuppetLint::VERSION}") }
  end

  context 'when passed multiple files' do
    let(:args) { [
      'spec/fixtures/test/manifests/warning.pp',
      'spec/fixtures/test/manifests/fail.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to eq([
      "#{args[0]} - WARNING: optional parameter listed before required parameter on line 2",
      "#{args[1]} - ERROR: test::foo not in autoload module layout on line 2",
    ].join("\n")) }
  end

  context 'when passed a malformed file' do
    let(:args) { 'spec/fixtures/test/manifests/malformed.pp' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to eq('ERROR: Syntax error (try running `puppet parser validate <file>`) on line 1') }
  end

  context 'when limited to errors only' do
    let(:args) { [
      '--error-level', 'error',
      'spec/fixtures/test/manifests/warning.pp',
      'spec/fixtures/test/manifests/fail.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(/^#{args.last} - ERROR/) }
  end

  context 'when limited to warnings only' do
    let(:args) { [
      '--error-level', 'warning',
      'spec/fixtures/test/manifests/warning.pp',
      'spec/fixtures/test/manifests/fail.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(/WARNING/) }
    its(:stdout) { is_expected.to_not match(/ERROR/) }
  end

  context 'when specifying a specific check to run' do
    let(:args) { [
      '--only-checks', 'parameter_order',
      'spec/fixtures/test/manifests/warning.pp',
      'spec/fixtures/test/manifests/fail.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to_not match(/ERROR/) }
    its(:stdout) { is_expected.to match(/WARNING/) }
  end

  context 'when asked to display filenames ' do
    let(:args) { ['--with-filename', 'spec/fixtures/test/manifests/fail.pp'] }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{^spec/fixtures/test/manifests/fail\.pp -}) }
  end

  context 'when not asked to fail on warnings' do
    let(:args) { ['spec/fixtures/test/manifests/warning.pp'] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(/optional parameter/) }
  end

  context 'when asked to provide context to problems' do
    let(:args) { [
      '--with-context',
      'spec/fixtures/test/manifests/warning.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to eq([
      'WARNING: optional parameter listed before required parameter on line 2',
      '',
      "  define test::warning($foo='bar', $baz) { }",
      '                                   ^',
    ].join("\n"))
    }
  end

  context 'when asked to fail on warnings' do
    let(:args) { [
      '--fail-on-warnings',
      'spec/fixtures/test/manifests/warning.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(/optional parameter/) }
  end

  context 'when used with an invalid option' do
    let(:args) { '--foo-bar-baz' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(/invalid option/) }
  end

  context 'when passed a file that does not exist' do
    let(:args) { 'spec/fixtures/test/manifests/enoent.pp' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(/specified file does not exist/) }
  end

  context 'when passed a directory' do
    let(:args) { 'spec/fixtures/' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(/ERROR/) }
  end

  context 'when disabling a check' do
    let(:args) { [
      '--no-autoloader_layout',
      'spec/fixtures/test/manifests/fail.pp'
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to eq("") }
  end

  context 'when changing the log format' do
    context 'to print %{filename}' do
      let(:args) { [
        '--log-format', '%{filename}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('fail.pp') }
    end

    context 'to print %{path}' do
      let(:args) { [
        '--log-format', '%{path}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('spec/fixtures/test/manifests/fail.pp') }
    end

    context 'to print %{fullpath}' do
      let(:args) { [
        '--log-format', '%{fullpath}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) {
        is_expected.to match(%r{^(/|[A-Za-z]\:).+/spec/fixtures/test/manifests/fail\.pp$})
      }
    end

    context 'to print %{line}' do
      let(:args) { [
        '--log-format', '%{line}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('2') }
    end

    context 'to print %{kind}' do
      let(:args) { [
        '--log-format', '%{kind}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('error') }
    end

    context 'to print %{KIND}' do
      let(:args) { [
        '--log-format', '%{KIND}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('ERROR') }
    end

    context 'to print %{check}' do
      let(:args) { [
        '--log-format', '%{check}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('autoloader_layout') }
    end

    context 'to print %{message}' do
      let(:args) { [
        '--log-format', '%{message}',
        'spec/fixtures/test/manifests/fail.pp'
      ] }

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('test::foo not in autoload module layout') }
    end
  end

  context 'when displaying results as json' do
    let(:args) { [
      '--json',
      'spec/fixtures/test/manifests/warning.pp',
    ] }
    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) do
      if respond_to?(:include_json)
        is_expected.to include_json([{'KIND' => 'WARNING'}])
      else
        is_expected.to match(/\[\n  \{/)
      end
    end
  end

  context 'when hiding ignored problems' do
    let(:args) { [
      'spec/fixtures/test/manifests/ignore.pp'
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to_not match(/IGNORED/) }
  end

  context 'when showing ignored problems' do
    let(:args) { [
      '--show-ignored',
      'spec/fixtures/test/manifests/ignore.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(/IGNORED/) }
  end

  context 'when showing ignored problems with a reason' do
    let(:args) { [
      '--show-ignored',
      'spec/fixtures/test/manifests/ignore_reason.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to eq([
      "IGNORED: double quoted string containing no variables on line 3",
      "  for a good reason",
    ].join("\n")) }
  end

  context 'ignoring multiple checks on a line' do
    let(:args) { [
      'spec/fixtures/test/manifests/ignore_multiple_line.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
  end

  context 'ignoring multiple checks in a block' do
    let(:args) { [
      'spec/fixtures/test/manifests/ignore_multiple_block.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(/^.*line 6$/) }
  end

  context 'when an lint:endignore control comment exists with no opening lint:ignore comment' do
    let(:args) { [
      'spec/fixtures/test/manifests/mismatched_control_comment.pp',
    ] }

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(/WARNING: lint:endignore comment with no opening lint:ignore:<check> comment found on line 1/) }
  end

  context 'when a lint:ignore control comment block is not terminated properly' do
    let(:args) { [
      'spec/fixtures/test/manifests/unterminated_control_comment.pp',
    ] }

    its(:stdout) { is_expected.to match(/WARNING: lint:ignore:140chars comment on line 2 with no closing lint:endignore comment/) }
  end
end
