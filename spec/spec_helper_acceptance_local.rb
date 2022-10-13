# frozen_string_literal: true

require 'shellwords'
require 'open3'
require 'rspec/expectations'

def puppet_lint(args = [])
  raise "Parameter 'args' should an Array but it was of type #{args.class}." unless args.is_a?(Array) || args.empty?

  bin_path = File.join(File.dirname(__FILE__), '..', 'bin', 'puppet-lint')

  command = [bin_path]
  command.concat(args) unless args.empty?

  stdout, stderr, status = Open3.capture3(*command)

  {
    stdout: stdout.chomp,
    stderr: stderr.chomp,
    exit_code: status.exitstatus,
  }
end

RSpec::Matchers.define :have_errors do |expected|
  match do |actual|
    actual.split("\n").count { |line| line.include?('ERROR') } == expected
  end

  diffable
end

RSpec::Matchers.define :have_warnings do |expected|
  match do |actual|
    actual.split("\n").count { |line| line.include?('WARNING') } == expected
  end

  diffable
end
