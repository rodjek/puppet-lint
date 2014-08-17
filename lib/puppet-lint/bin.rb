require 'puppet-lint/optparser'

# Internal: The logic of the puppet-lint bin script, contained in a class for
# ease of testing.
class PuppetLint::Bin
  # Public: Initialise a new PuppetLint::Bin.
  #
  # args - An Array of command line argument Strings to be passed to the option
  #        parser.
  #
  # Examples
  #
  #   PuppetLint::Bin.new(ARGV).run
  def initialize(args)
    @args = args
  end

  # Public: Run puppet-lint as a command line tool.
  #
  # Returns an Integer exit code to be passed back to the shell.
  def run
    opts = PuppetLint::OptParser.build

    begin
      opts.parse!(@args)
    rescue OptionParser::InvalidOption
      puts "puppet-lint: #{$!.message}"
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      return 1
    end

    if PuppetLint.configuration.display_version
      puts "puppet-lint #{PuppetLint::VERSION}"
      return 0
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

      if path.length > 1
        PuppetLint.configuration.with_filename = true
      end

      return_val = 0
      path.each do |f|
        l = PuppetLint.new
        l.file = f
        l.run
        l.print_problems
        if l.errors? or (l.warnings? and PuppetLint.configuration.fail_on_warnings)
          return_val = 1
        end

        if PuppetLint.configuration.fix && !l.problems.any? { |e| e[:check] == :syntax }
          File.open(f, 'w') do |fd|
            fd.write l.manifest
          end
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
