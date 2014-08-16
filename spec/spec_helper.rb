require 'puppet-lint'
require 'rspec/its'
require 'rspec/collection_matchers'

module RSpec
  module LintExampleGroup
    class HaveProblem
      def initialize(method, message)
        @expected_problem = {
          :kind    => method.to_s.gsub(/\Acontain_/, '').to_sym,
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
          ret = true
          @expected_problem.each do |key, value|
            if !problem.key?(key)
              ret = false
              break
            elsif problem[key] != value
              ret = false
              break
            end
          end
          ret
        end
      end

      def description
        @description.join(' ')
      end

      def check_attr(attr, prefix)
        unless @expected_problem[attr] == @problems.first[attr]
          expected = @expected_problem[attr].inspect
          actual = @problems.first[attr].inspect
          "#{prefix} #{expected}, but it was #{actual}"
        end
      end

      def failure_message
        case @problems.length
        when 0
          "expected that the check would create a problem but it did not"
        when 1
          messages = ["expected that the problem"]

          messages << check_attr(:kind, 'would be of kind')
          messages << check_attr(:message, 'would have the message')
          messages << check_attr(:linenumber, 'would be on line')
          messages << check_attr(:column, 'would start on column')

          messages.compact.join("\n  ")
        else
          [
            "expected that the check would create",
            PP.pp(@expected_problem, '').strip,
            "but it instead created",
            PP.pp(@problems, ''),
          ].join("\n")
        end
      end

      def failure_message_when_negated
        "expected that the check would not create the problem, but it did"
      end
    end

    def method_missing(method, *args, &block)
      return HaveProblem.new(method, args.first) if method.to_s =~ /\Acontain_/
      super
    end

    def problems
      subject.problems
    end

    def manifest
      subject.manifest
    end

    def subject
      klass = PuppetLint::Checks.new
      filepath = self.respond_to?(:path) ? path : ''
      klass.load_data(filepath, code)
      check_name = self.class.top_level_description.to_sym
      check = PuppetLint.configuration.check_object[check_name].new
      klass.problems = check.run
      if PuppetLint.configuration.fix
        klass.problems = check.fix_problems
      end
      klass
    end
  end
end

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.include RSpec::LintExampleGroup, {
    :type      => :lint,
    :file_path => Regexp.compile(%w{spec puppet-lint plugins}.join('[\\\/]')),
  }
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
