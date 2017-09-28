require 'simplecov'
SimpleCov.start do
  add_filter('/spec/')
  add_filter('/vendor/')
  add_group('Checks', 'lib/puppet-lint/plugins')
end

require 'puppet-lint'
require 'rspec/its'
require 'rspec/collection_matchers'
begin
  require 'rspec/json_expectations'
rescue LoadError, SyntaxError
  puts 'rspec/json_expectations is not available'
end

module RSpec
  module LintExampleGroup
    class HaveProblem
      def initialize(method, message)
        @expected_problem = {
          :kind    => method.to_s.gsub(%r{\Acontain_}, '').to_sym,
          :message => message,
        }
        @description = ["contain a #{@expected_problem[:kind]}"]
      end

      def on_line(line)
        @expected_problem[:line] = line
        @description << "on line #{line}"
        self
      end

      def in_column(column)
        @expected_problem[:column] = column
        @description << "starting in column #{column}"
        self
      end

      def with_reason(reason)
        @expected_problem[:reason] = reason
        @description << "with reason '#{reason}'"
        self
      end

      def matches?(problems)
        @problems = problems

        problems.any? do |problem|
          @expected_problem.all? do |key, value|
            problem.key?(key) && problem[key] == value
          end
        end
      end

      def description
        @description.join(' ')
      end

      def check_attr(attr, prefix)
        return if @expected_problem[attr] == @problems.first[attr]

        expected = @expected_problem[attr].inspect
        actual = @problems.first[attr].inspect
        "#{prefix} #{expected}, but it was #{actual}"
      end

      def failure_message
        case @problems.length
        when 0
          'expected that the check would create a problem but it did not'
        when 1
          messages = ['expected that the problem']

          messages << check_attr(:kind, 'would be of kind')
          messages << check_attr(:message, 'would have the message')
          messages << check_attr(:line, 'would be on line')
          messages << check_attr(:column, 'would start on column')
          messages << check_attr(:reason, 'would have the reason')

          messages.compact.join("\n  ")
        else
          [
            'expected that the check would create',
            PP.pp(@expected_problem, '').strip,
            'but it instead created',
            PP.pp(@problems, ''),
          ].join("\n")
        end
      end

      def failure_message_when_negated
        'expected that the check would not create the problem, but it did'
      end
    end

    def method_missing(method, *args, &block)
      return HaveProblem.new(method, args.first) if method.to_s.start_with?('contain_')
      super
    end

    def respond_to_missing?(method, *)
      method.to_s.start_with?('contain_') || super
    end

    def problems
      subject.problems
    end

    def manifest
      subject.manifest
    end

    def subject
      klass = PuppetLint::Checks.new
      filepath = respond_to?(:path) ? path : ''
      klass.load_data(filepath, code)
      check_name = self.class.top_level_description.to_sym
      check = PuppetLint.configuration.check_object[check_name].new
      klass.problems = check.run

      klass.problems = check.fix_problems if PuppetLint.configuration.fix

      klass
    end
  end
end

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.include(
    RSpec::LintExampleGroup,
    :type      => :lint,
    :file_path => Regexp.compile(%w[spec puppet-lint plugins].join('[\\\/]'))
  )

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
