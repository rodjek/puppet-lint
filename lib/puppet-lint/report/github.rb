# frozen_string_literal: true

class PuppetLint::Report
  # This formatter formats report data as GitHub Workflow commands resulting
  # in GitHub check annotations when run within GitHub Actions.
  class GitHubActionsReporter
    ESCAPE_MAP = { '%' => '%25', "\n" => '%0A', "\r" => '%0D' }.freeze

    def self.format_problem(file, problem)
      "\n::#{problem[:kind]} file=#{file},line=#{problem[:line]},col=#{problem[:column]}::#{github_escape(problem[:message])} (check: #{problem[:check]})\n"
    end

    def self.github_escape(string)
      string.gsub(Regexp.union(ESCAPE_MAP.keys), ESCAPE_MAP)
    end
  end
end
