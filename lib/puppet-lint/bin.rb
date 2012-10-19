require 'optparse'

class PuppetLint::Bin
  def initialize(args)
    @args = args
  end

  def run
    help = <<-EOHELP
    Puppet-lint

    Basic Command Line Usage:
      puppet-lint [OPTIONS] [PATH]

            PATH                         The path to the Puppet manifest.

    Options:
    EOHELP

    opts = OptionParser.new do |opts|
      opts.banner = help

      opts.on("--version", "Display current version.") do
        puts "Puppet-lint " + PuppetLint::VERSION
        return 0
      end

      opts.on('--with-context', 'Show where in the manifest the problem is') do
        PuppetLint.configuration.with_context = true
      end

      opts.on("--with-filename", "Display the filename before the warning") do
        PuppetLint.configuration.with_filename = true
      end

      opts.on("--fail-on-warnings", "Return a non-zero exit status for warnings.") do
        PuppetLint.configuration.fail_on_warnings = true
      end

      opts.on("--error-level LEVEL", [:all, :warning, :error], "The level of error to return.", "(warning, error, all)") do |el|
        PuppetLint.configuration.error_level = el
      end

      opts.on("--log-format FORMAT",
        "Change the log format.", "Overrides --with-filename.",
        "The following placeholders can be used:",
        "%{filename}   - Filename without path.",
        "%{path}       - Path as provided.",
        "%{fullpath}   - Full path.",
        "%{linenumber} - Line number.",
        "%{kind}       - The kind of message.",
        "              - (warning, error)",
        "%{KIND}       - Uppercase version of %{kind}",
        "%{check}      - Name of the check.",
        "%{message}    - The message."
      ) do |format|
        PuppetLint.configuration.log_format = format
      end

      opts.separator ""
      opts.separator "    Disable checks:"

      PuppetLint.configuration.checks.each do |check|
        opts.on("--no-#{check}-check", "Skip the #{check} check") do
          PuppetLint.configuration.send("disable_#{check}")
        end
      end

      opts.load('/etc/puppet-lint.rc')

      if ENV['HOME']
        opts.load(File.expand_path('~/.puppet-lint.rc'))
        if opts.load(File.expand_path('~/.puppet-lintrc'))
          $stderr.puts 'Depreciated: Found ~/.puppet-lintrc instead of ~/.puppet-lint.rc'
        end
      end

      opts.load('.puppet-lint.rc')
      if opts.load('.puppet-lintrc')
        $stderr.puts 'Depreciated: Read .puppet-lintrc instead of .puppet-lint.rc'
      end
    end

    begin
      opts.parse!(@args)
    rescue OptionParser::InvalidOption
      puts "puppet-lint: #{$!.message}"
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      return 1
    end

    if @args[0].nil?
      puts "puppet-lint: no file specified"
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      return 1
    end

    begin
      path = @args[0]
      if File.directory?(path)
        path = Dir.glob("#{path}/**/*.pp")
      else
        path = @args
      end

      return_val = 0
      path.each do |f|
        l = PuppetLint.new
        l.file = f
        l.run
        if l.errors? or (l.warnings? and PuppetLint.configuration.fail_on_warnings)
          return_val = 1
        end
      end
      return return_val

    rescue PuppetLint::NoCodeError
      puts "puppet-lint: no file specified or specified file does not exist"
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      return 1
    end
  end
end
