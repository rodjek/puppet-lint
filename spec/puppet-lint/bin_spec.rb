require 'spec_helper'
require 'rspec/mocks'
require 'optparse'
require 'tempfile'

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
    sane_args = if args.is_a?(Array)
                  args
                else
                  [args]
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

  context 'when asked to display available checks' do
    let(:args) { '--list-checks' }
    all_checks = PuppetLint.configuration.checks.map(&:to_s)

    its(:exitstatus) { is_expected.to eq(0) }

    all_checks.each do |c|
      it "includes check #{c} in its output" do
        expect(subject.stdout).to include c
      end
    end
  end

  context 'when passed a backslash separated path on Windows', :if => Gem.win_platform? do
    let(:args) do
      [
        'spec\fixtures\test\manifests',
      ]
    end

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{spec/fixtures/test/manifests/warning\.pp - WARNING: optional}m) }
  end

  context 'when passed multiple files' do
    let(:args) do
      [
        'spec/fixtures/test/manifests/warning.pp',
        'spec/fixtures/test/manifests/fail.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) do
      is_expected.to eq(
        [
          "#{args[0]} - WARNING: optional parameter listed before required parameter on line 2",
          "#{args[1]} - ERROR: test::foo not in autoload module layout on line 2",
        ].join("\n")
      )
    end
  end

  context 'when passed a malformed file' do
    let(:args) { 'spec/fixtures/test/manifests/malformed.pp' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to eq('ERROR: Syntax error on line 1') }
    its(:stderr) { is_expected.to eq('Try running `puppet parser validate <file>`') }
  end

  context 'when passed ignore paths option' do
    let(:args) do
      [
        '--ignore-paths',
        'spec/*',
        'spec/fixtures/test/manifests/malformed.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to eq('') }
  end

  context 'when limited to errors only' do
    let(:args) do
      [
        '--error-level',
        'error',
        'spec/fixtures/test/manifests/warning.pp',
        'spec/fixtures/test/manifests/fail.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{^#{args.last} - ERROR}) }
  end

  context 'when limited to warnings only' do
    let(:args) do
      [
        '--error-level',
        'warning',
        'spec/fixtures/test/manifests/warning.pp',
        'spec/fixtures/test/manifests/fail.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{WARNING}) }
    its(:stdout) { is_expected.to_not match(%r{ERROR}) }
  end

  context 'when specifying a specific check to run' do
    let(:args) do
      [
        '--only-checks',
        'parameter_order',
        'spec/fixtures/test/manifests/warning.pp',
        'spec/fixtures/test/manifests/fail.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to_not match(%r{ERROR}) }
    its(:stdout) { is_expected.to match(%r{WARNING}) }
  end

  context 'when asked to display filenames ' do
    let(:args) do
      [
        '--with-filename',
        'spec/fixtures/test/manifests/fail.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{^spec/fixtures/test/manifests/fail\.pp -}) }
  end

  context 'when not asked to fail on warnings' do
    let(:args) do
      [
        'spec/fixtures/test/manifests/warning.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(%r{optional parameter}) }
  end

  context 'when asked to provide context to problems' do
    let(:args) do
      [
        '--with-context',
        'spec/fixtures/test/manifests/warning.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) do
      is_expected.to eq(
        [
          'WARNING: optional parameter listed before required parameter on line 2',
          '',
          "  define test::warning($foo='bar', $baz) { }",
          '                                   ^',
        ].join("\n")
      )
    end
  end

  context 'when asked to fail on warnings' do
    let(:args) do
      [
        '--fail-on-warnings',
        'spec/fixtures/test/manifests/warning.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{optional parameter}) }
  end

  context 'when used with an invalid option' do
    let(:args) { '--foo-bar-baz' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{invalid option}) }
  end

  context 'when passed a file that does not exist' do
    let(:args) { 'spec/fixtures/test/manifests/enoent.pp' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{specified file does not exist}) }
  end

  context 'when passed a directory' do
    let(:args) { 'spec/fixtures/' }

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) { is_expected.to match(%r{ERROR}) }
  end

  context 'when disabling a check' do
    let(:args) do
      [
        '--no-autoloader_layout',
        'spec/fixtures/test/manifests/fail.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to eq('') }
  end

  context 'when changing the log format' do
    context 'to print %{filename}' do
      let(:args) do
        [
          '--log-format',
          '%{filename}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('fail.pp') }
    end

    context 'to print %{path}' do
      let(:args) do
        [
          '--log-format',
          '%{path}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('spec/fixtures/test/manifests/fail.pp') }
    end

    context 'to print %{fullpath}' do
      let(:args) do
        [
          '--log-format',
          '%{fullpath}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) do
        is_expected.to match(%r{^(/|[A-Za-z]\:).+/spec/fixtures/test/manifests/fail\.pp$})
      end
    end

    context 'to print %{line}' do
      let(:args) do
        [
          '--log-format',
          '%{line}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('2') }
    end

    context 'to print %{kind}' do
      let(:args) do
        [
          '--log-format',
          '%{kind}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('error') }
    end

    context 'to print %{KIND}' do
      let(:args) do
        [
          '--log-format',
          '%{KIND}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('ERROR') }
    end

    context 'to print %{check}' do
      let(:args) do
        [
          '--log-format',
          '%{check}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('autoloader_layout') }
    end

    context 'to print %{message}' do
      let(:args) do
        [
          '--log-format',
          '%{message}',
          'spec/fixtures/test/manifests/fail.pp',
        ]
      end

      its(:exitstatus) { is_expected.to eq(1) }
      its(:stdout) { is_expected.to eq('test::foo not in autoload module layout') }
    end
  end

  context 'when displaying results as json' do
    let(:args) do
      [
        '--json',
        'spec/fixtures/test/manifests/warning.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) do
      if respond_to?(:include_json)
        is_expected.to include_json([[{ 'KIND' => 'WARNING' }]])
      else
        is_expected.to match(%r{\[\n  \{})
      end
    end
  end

  context 'when displaying results for multiple targets as json' do
    let(:args) do
      [
        '--json',
        'spec/fixtures/test/manifests/fail.pp',
        'spec/fixtures/test/manifests/warning.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(1) }
    its(:stdout) do
      if respond_to?(:include_json)
        is_expected.to include_json([[{ 'KIND' => 'ERROR' }], [{ 'KIND' => 'WARNING' }]])
      else
        is_expected.to match(%r{\[\n  \{})
      end
    end
  end

  context 'when hiding ignored problems' do
    let(:args) do
      [
        'spec/fixtures/test/manifests/ignore.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to_not match(%r{IGNORED}) }
  end

  context 'when showing ignored problems' do
    let(:args) do
      [
        '--show-ignored',
        'spec/fixtures/test/manifests/ignore.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(%r{IGNORED}) }
  end

  context 'when showing ignored problems with a reason' do
    let(:args) do
      [
        '--show-ignored',
        'spec/fixtures/test/manifests/ignore_reason.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) do
      is_expected.to eq(
        [
          'IGNORED: double quoted string containing no variables on line 3',
          '  for a good reason',
        ].join("\n")
      )
    end
  end

  context 'ignoring multiple checks on a line' do
    let(:args) do
      [
        'spec/fixtures/test/manifests/ignore_multiple_line.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
  end

  context 'ignoring multiple checks in a block' do
    let(:args) do
      [
        'spec/fixtures/test/manifests/ignore_multiple_block.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(%r{^.*line 6$}) }
  end

  context 'when an lint:endignore control comment exists with no opening lint:ignore comment' do
    let(:args) do
      [
        'spec/fixtures/test/manifests/mismatched_control_comment.pp',
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }
    its(:stdout) { is_expected.to match(%r{WARNING: lint:endignore comment with no opening lint:ignore:<check> comment found on line 1}) }
  end

  context 'when a lint:ignore control comment block is not terminated properly' do
    let(:args) do
      [
        'spec/fixtures/test/manifests/unterminated_control_comment.pp',
      ]
    end

    its(:stdout) { is_expected.to match(%r{WARNING: lint:ignore:140chars comment on line 2 with no closing lint:endignore comment}) }
  end

  context 'when fixing a file with \n line endings' do
    before(:context) do
      @windows_file = Tempfile.new('windows')
      @posix_file = Tempfile.new('posix')

      @windows_file.binmode
      @posix_file.binmode

      @windows_file.write("\r\n")
      @posix_file.write("\n")

      @windows_file.close
      @posix_file.close
    end

    after(:context) do
      @windows_file.unlink
      @posix_file.unlink
    end

    let(:args) do
      [
        '--fix',
        @posix_file.path,
        @windows_file.path,
      ]
    end

    its(:exitstatus) { is_expected.to eq(0) }

    it 'does not change the line endings' do
      File.open(@posix_file.path, 'rb') do |f|
        data = f.read

        expect(data).to match(%r{\n\Z}m)
        expect(data).to_not match(%r{\r\n\Z}m)
      end

      File.open(@windows_file.path, 'rb') do |f|
        data = f.read

        expect(data).to match(%r{\r\n\Z}m)
      end
    end
  end
end
