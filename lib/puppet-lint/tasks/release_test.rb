require 'rake'
require 'open3'
require 'English'

def run_cmd(message, *cmd)
  print("  #{message}... ")

  if Open3.respond_to?(:capture2e)
    output, status = Open3.capture2e(*cmd)
  else
    output = ''

    Open3.popen3(*cmd) do |stdin, stdout, stderr|
      stdin.close
      output += stdout.read
      output += stderr.read
    end
    status = $CHILD_STATUS.dup
  end

  if status.success?
    puts 'Done'
  else
    puts 'FAILED'
  end

  [output.strip, status.success?]
end

def with_puppet_lint_head
  print('  Updating Gemfile to use puppet-lint HEAD... ')

  buffer = Parser::Source::Buffer.new('Gemfile')
  buffer.source = File.read('Gemfile')
  parser = Parser::CurrentRuby.new
  ast = parser.parse(buffer)

  modified_gemfile = GemfileRewrite.new.rewrite(buffer, ast)
  if modified_gemfile == buffer.source
    puppet_lint_root = File.expand_path(File.join(__FILE__, '..', '..', '..', '..'))
    File.open('Gemfile', 'a') do |f|
      f.puts "gem 'puppet-lint', :path => '#{puppet_lint_root}'"
    end
  else
    File.open('Gemfile', 'w') do |f|
      f.puts modified_gemfile
    end
  end

  puts 'Done'

  Bundler.with_clean_env { yield }

  run_cmd('Restoring Gemfile', 'git', 'checkout', '--', 'Gemfile')
end

task :release_test do
  branch = if ENV['APPVEYOR']
             ENV['APPVEYOR_PULL_REQUEST_HEAD_REPO_BRANCH']
           elsif ENV['TRAVIS']
             ENV['TRAVIS_PULL_REQUEST_BRANCH']
           else
             false
           end

  if branch && branch !~ %r{\A\d+_\d+_\d+_release\Z}
    puts 'Skipping release tests on feature branch'
    exit
  end

  if RUBY_VERSION.start_with?('1')
    puts 'Unable to run release_tests on Ruby < 2.0'
    exit
  end

  require 'puppet-lint/tasks/gemfile_rewrite'

  modules_to_test = [
    'puppetlabs/puppetlabs-apt',
    'puppetlabs/puppetlabs-tomcat',
    'puppetlabs/puppetlabs-apache',
    'puppetlabs/puppetlabs-mysql',
    'puppetlabs/puppetlabs-ntp',
    'puppetlabs/puppetlabs-chocolatey',
    'voxpupuli/puppet-archive',
    'voxpupuli/puppet-collectd',
    'garethr/garethr-docker',
    'sensu/sensu-puppet',
    'jenkinsci/puppet-jenkins',
  ]

  FileUtils.mkdir_p('tmp')
  Dir.chdir('tmp') do
    modules_to_test.each do |module_name|
      puts "Testing #{module_name}..."
      module_dir = File.basename(module_name)

      if File.directory?(module_dir)
        Dir.chdir(module_dir) do
          _, success = run_cmd('Updating repository', 'git', 'pull', '--rebase')
          next unless success
        end
      else
        _, success = run_cmd('Cloning repository', 'git', 'clone', "https://github.com/#{module_name}")
        next unless success
      end

      Dir.chdir(module_dir) do
        with_puppet_lint_head do
          _, success = run_cmd('Installing dependencies', 'bundle', 'install', '--path', File.join('..', 'vendor', 'gems'))
          next unless success

          output, success = run_cmd('Running puppet-lint CLI', 'bundle', 'exec', 'puppet-lint', '--relative', '--no-documentation-check', 'manifests')
          unless output.empty?
            output.split("\n").each do |line|
              puts "    #{line}"
            end
          end

          output, success = run_cmd('Running puppet-lint Rake task', 'bundle', 'exec', 'rake', 'lint')
          unless output.empty?
            output.split("\n").each do |line|
              puts "    #{line}"
            end
          end
        end
      end
    end
  end
end
