require 'rubygems'
require 'puppet-lint'

task :lint do
  linter =  PuppetLint.new
  Dir.glob('**/*.pp').each do |puppet_file|
    puts "Evaluating #{puppet_file}"
    linter.file = puppet_file
    linter.run
  end
  fail if linter.errors?
end
