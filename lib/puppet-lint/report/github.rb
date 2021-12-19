# frozen_string_literal: true

class PuppetLint
  module Report
    # This formatter formats report data as GitHub Workflow commands resulting
    # in GitHub check annotations when run within GitHub Actions.
    class GitHubActionsReporter
      ESCAPE_MAP = { '%' => '%25', "\n" => '%0A', "\r" => '%0D' }.freeze

      def self.format_problem(file, problem)
        format(
          "\n::%<severity>s file=%<file>s,line=%<line>d,col=%<column>d::%<message>s (check: %<check>s)\n",
          :severity => problem[:kind],
          :file => file,
          :line => problem[:line],
          :column => problem[:column],
          :message => github_escape(problem[:message]),
          :check => problem[:check]
        )
      end

      def self.github_escape(string)
        string.gsub(Regexp.union(ESCAPE_MAP.keys), ESCAPE_MAP)
      end
    end
  end
end
