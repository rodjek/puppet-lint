require 'spec_helper'

describe PuppetLint::Checks do
  subject(:instance) { described_class.new }

  let(:path) { File.join('path', 'to', 'test.pp') }
  let(:content) { "notify { 'test': }" }

  describe '#initialize' do
    it { is_expected.to have_attributes(:problems => []) }
  end

  describe '#load_data' do
    let(:lexer) { PuppetLint::Lexer.new }

    before do
      allow(PuppetLint::Lexer).to receive(:new).and_return(lexer)
    end

    context 'when the tokeniser encounters an error' do
      before do
        allow(lexer).to receive(:tokenise).with(content).and_raise(lexer_error)
        instance.load_data(path, content)
      end

      context 'and the reason for the error is unknown' do
        let(:lexer_error) { PuppetLint::LexerError.new(1, 2) }

        it 'stores an empty tokens array' do
          expect(PuppetLint::Data.tokens).to be_empty
        end

        it 'creates a syntax error problem for the file' do
          expect(instance.problems).to have(1).problem
          expect(instance.problems.first).to include(
            :kind     => :error,
            :check    => :syntax,
            :message  => 'Syntax error',
            :line     => 1,
            :column   => 2,
            :path     => anything,
            :fullpath => anything,
            :filename => anything
          )
        end
      end

      context 'and the reason for the error is known' do
        let(:lexer_error) { PuppetLint::LexerError.new(1, 2, 'some reason') }

        it 'stores an empty tokens array' do
          expect(PuppetLint::Data.tokens).to be_empty
        end

        it 'creates a syntax error problem for the file' do
          expect(instance.problems).to have(1).problem
          expect(instance.problems.first).to include(
            :kind     => :error,
            :check    => :syntax,
            :message  => 'Syntax error (some reason)',
            :line     => 1,
            :column   => 2,
            :path     => anything,
            :fullpath => anything,
            :filename => anything
          )
        end
      end
    end
  end

  describe '#run' do
    let(:fileinfo) { File.join('path', 'to', 'test.pp') }
    let(:data) { "notify { 'test': }" }
    let(:enabled_checks) { [] }

    before do
      allow(instance).to receive(:enabled_checks).and_return(enabled_checks)
    end

    it 'loads the manifest data' do
      expect(instance).to receive(:load_data).with(fileinfo, data).and_call_original
      instance.run(fileinfo, data)
    end

    context 'when there are checks enabled' do
      let(:enabled_checks) { [:arrow_alignment, :hard_tabs] }
      let(:enabled_check_classes) { enabled_checks.map { |r| PuppetLint.configuration.check_object[r] } }
      let(:disabled_checks) { PuppetLint.configuration.checks - enabled_checks }
      let(:disabled_check_classes) { disabled_checks.map { |r| PuppetLint.configuration.check_object[r] } }

      it 'runs the enabled checks' do
        expect(enabled_check_classes).to all(receive(:new).and_call_original)

        instance.run(fileinfo, data)
      end

      it 'does not run the disabled checks' do
        # expect().to_not all(matcher) is not supported
        disabled_check_classes.each do |check_class|
          expect(check_class).to_not receive(:new)
        end

        instance.run(fileinfo, data)
      end

      context 'when a check finds a problem in the manifest' do
        let(:arrow_alignment_check) { PuppetLint.configuration.check_object[:arrow_alignment] }
        let(:hard_tabs_check) { PuppetLint.configuration.check_object[:hard_tabs] }
        let(:mock_arrow_alignment) do
          instance_double(
            PuppetLint::CheckPlugin,
            :run          => [{ :kind => :error, :check => :arrow_alignment }],
            :fix_problems => [{ :kind => :fixed, :check => :arrow_alignment }]
          )
        end
        let(:mock_hard_tabs) do
          instance_double(PuppetLint::CheckPlugin, :run => [], :fix_problems => [])
        end
        let(:fix_state) { false }

        before(:each) do
          allow(arrow_alignment_check).to receive(:new).and_return(mock_arrow_alignment)
          allow(hard_tabs_check).to receive(:new).and_return(mock_hard_tabs)
          allow(PuppetLint.configuration).to receive(:fix).and_return(fix_state)
          instance.run(fileinfo, data)
        end

        it 'adds the found problems to the problems array' do
          expect(instance).to have_attributes(:problems => [{ :kind => :error, :check => :arrow_alignment }])
        end

        context 'and fix is enabled' do
          let(:fix_state) { true }

          it 'calls #fix_problems on the check and adds the results to the problems array' do
            expect(instance).to have_attributes(:problems => [{ :kind => :fixed, :check => :arrow_alignment }])
          end
        end
      end
    end

    context 'when an unhandled exception is raised' do
      before do
        allow(instance).to receive(:load_data).with(fileinfo, data).and_raise(StandardError.new('test message'))
        allow($stdout).to receive(:puts).with(anything)
      end

      it 'prints out information about the puppet-lint version and ruby environment' do
        expected_info = [
          "puppet-lint version: #{PuppetLint::VERSION}",
          "ruby version: #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}",
          "platform: #{RUBY_PLATFORM}",
        ]
        pattern = expected_info.map { |r| Regexp.escape(r) }.join('\s+')
        expect($stdout).to receive(:puts).with(a_string_matching(%r{#{pattern}}m))

        expect {
          instance.run(fileinfo, data)
        }.to raise_error(SystemExit) { |error|
          expect(error.status).to eq(1)
        }
      end

      it 'prints out the details of the exception raised' do
        expect($stdout).to receive(:puts).with(a_string_matching(%r{error:\s+```\s+StandardError: test message.+```}m))

        expect {
          instance.run(fileinfo, data)
        }.to raise_error(SystemExit) { |error|
          expect(error.status).to eq(1)
        }
      end

      context 'and the file being linted is readable' do
        before do
          allow(File).to receive(:readable?).with(fileinfo).and_return(true)
          allow(File).to receive(:read).with(fileinfo).and_return(data)
        end

        it 'adds the contents of the file to the bug report' do
          expect($stdout).to receive(:puts).with("file contents:\n```\n#{data}\n```")

          expect {
            instance.run(fileinfo, data)
          }.to raise_error(SystemExit) { |error|
            expect(error.status).to eq(1)
          }
        end
      end
    end
  end

  describe '#enabled_checks' do
    subject(:enabled_checks) { instance.enabled_checks }

    let(:expected_enabled_checks) { [:arrow_alignment, :trailing_whitespace] }

    before do
      PuppetLint.configuration.checks.each do |check|
        allow(PuppetLint.configuration).to receive("#{check}_enabled?").and_return(expected_enabled_checks.include?(check))
      end
    end

    it 'checks the configuration for each check to see if it is enabled' do
      expect(enabled_checks.map(&:to_s).sort).to eq(expected_enabled_checks.map(&:to_s).sort)
    end
  end

  describe '#manifest' do
    subject(:manifest) { instance.manifest }

    let(:tokens) do
      [
        instance_double(PuppetLint::Lexer::Token, :to_manifest => '1'),
        instance_double(PuppetLint::Lexer::Token, :to_manifest => '2'),
        instance_double(PuppetLint::Lexer::Token, :to_manifest => '3'),
      ]
    end

    before do
      allow(PuppetLint::Data).to receive(:tokens).and_return(tokens)
    end

    it 'reassembles the manifest from the tokens array' do
      expect(manifest).to eq('123')
    end
  end
end
