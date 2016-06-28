require 'optparse'

# Public: Contains the puppet-lint option parser so that it can be used easily
# in multiple places.
class PuppetLint::OptParser
  HELP_TEXT = <<-EOF
    puppet-lint

    Basic Command Line Usage:
      puppet-lint [OPTIONS] PATH

            PATH                         The path to the Puppet manifest.

    Option:
  EOF

  # Public: Initialise a new puppet-lint OptionParser.
  #
  # Returns an OptionParser object.
  def self.build
    OptionParser.new do |opts|
      opts.banner = HELP_TEXT

      opts.on('--version', 'Display the current version.') do
        PuppetLint.configuration.display_version = true
      end

      opts.on('-c', '--config FILE', 'Load puppet-lint options from file.') do |file|
        opts.load(file)
      end

      opts.on('--with-context', 'Show where in the manifest the problem is.') do
        PuppetLint.configuration.with_context = true
      end

      opts.on('--with-filename', 'Display the filename before the warning.') do
        PuppetLint.configuration.with_filename = true
      end

      opts.on('--fail-on-warnings', 'Return a non-zero exit status for warnings') do
        PuppetLint.configuration.fail_on_warnings = true
      end

      opts.on('--error-level LEVEL', [:all, :warning, :error],
              'The level of error to return (warning, error or all).') do |el|
        PuppetLint.configuration.error_level = el
      end

      opts.on('--show-ignored', 'Show problems that have been ignored by control comments') do
        PuppetLint.configuration.show_ignored = true
      end

      opts.on('--relative', 'Compare module layout relative to the module root') do
        PuppetLint.configuration.relative = true
      end

      opts.on('-l', '--load FILE', 'Load a file containing custom puppet-lint checks.') do |f|
        load f
      end

      opts.on('--load-from-puppet MODULEPATH', 'Load plugins from the given Puppet module path.') do |path|
        path.split(':').each do |p|
          Dir["#{p}/*/lib/puppet-lint/plugins/*.rb"].each do |file|
            load file
          end
        end
      end

      opts.on('-f', '--fix', 'Attempt to automatically fix errors') do
        PuppetLint.configuration.fix = true
      end

      opts.on('--log-format FORMAT',
              'Change the log format.', 'Overrides --with-filename.',
              'The following placeholders can be used:',
              '%{filename} - Filename without path.',
              '%{path}     - Path as provided to puppet-lint.',
              '%{fullpath} - Expanded path to the file.',
              '%{line}     - Line number.',
              '%{column}   - Column number.',
              '%{kind}     - The kind of message (warning, error).',
              '%{KIND}     - Uppercase version of %{kind}.',
              '%{check}    - The name of the check.',
              '%{message}  - The message.'
      ) do |format|
        if format.include?('%{linenumber}')
          $stderr.puts "DEPRECATION: Please use %{line} instead of %{linenumber}"
        end
        PuppetLint.configuration.log_format = format
      end

      opts.separator ''
      opts.separator '    Checks:'

      opts.on('--only-checks CHECKS', 'A comma separated list of checks that should be run') do |checks|
        enable_checks = checks.split(',').map(&:to_sym)
        (PuppetLint.configuration.checks).each do |check|
          if enable_checks.include? check
            PuppetLint.configuration.send("enable_#{check}")
          else
            PuppetLint.configuration.send("disable_#{check}")
          end
        end
      end

      PuppetLint.configuration.checks.each do |check|
        opts.on("--no-#{check}-check", "Skip the #{check} check.") do
          PuppetLint.configuration.send("disable_#{check}")
        end
        unless PuppetLint.configuration.send("#{check}_enabled?")
          opts.on("--#{check}-check", "Enable the #{check} check.") do
            PuppetLint.configuration.send("enable_#{check}")
          end
        end
      end

      opts.load('/etc/puppet-lint.rc')
      begin
        opts.load(File.expand_path('~/.puppet-lint.rc')) if ENV['HOME']
      rescue Errno::EACCES
        # silently skip loading this file if HOME is set to a directory that
        # the user doesn't have read access to.
      end
      opts.load('.puppet-lint.rc')
    end
  end
end
