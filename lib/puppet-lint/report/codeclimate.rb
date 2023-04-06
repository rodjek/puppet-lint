# frozen_string_literal: true

require 'digest'
require 'json'

# rubocop:disable Style/ClassAndModuleChildren
class PuppetLint::Report
  # Formats problems and writes them to a file as a code climate compatible report.
  class CodeClimateReporter
    def self.write_report_file(problems, report_file)
      report = []
      problems.each do |messages|
        messages.each do |message|
          case message[:kind]
          when :warning
            severity = 'minor'
          when :error
            severity = 'major'
          else
            next
          end

          issue = {
            type: :issue,
            check_name: message[:check],
            description: message[:message],
            categories: [:Style],
            severity: severity,
            location: {
              path: message[:path],
              lines: {
                begin: message[:line],
                end: message[:line]
              }
            }
          }

          issue[:fingerprint] = Digest::MD5.hexdigest(Marshal.dump(issue))

          if message.key?(:description) && message.key?(:help_uri)
            issue[:content] = "#{message[:description].chomp('.')}. See [this page](#{message[:help_uri]}) for more information about the `#{message[:check]}` check."
          end
          report << issue
        end
      end
      File.write(report_file, "#{JSON.pretty_generate(report)}\n")
    end
  end
end
