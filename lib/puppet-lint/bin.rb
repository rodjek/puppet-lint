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
    begin
      opts = PuppetLint::OptParser.build(@args)
      opts.parse!(@args)
    rescue OptionParser::InvalidOption => e
      puts "puppet-lint: #{e.message}"
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      return 1
    end

    if PuppetLint.configuration.display_version
      puts "puppet-lint #{PuppetLint::VERSION}"
      return 0
    end

    if PuppetLint.configuration.list_checks
      puts PuppetLint.configuration.checks
      return 0
    end

    if @args[0].nil?
      puts 'puppet-lint: no file specified'
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      return 1
    end

    begin
      path = @args[0]
      path = path.gsub(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
      path = if File.directory?(path)
               Dir.glob("#{path}/**/*.pp")
             else
               @args
             end

      PuppetLint.configuration.with_filename = true if path.length > 1

      return_val = 0
      ignore_paths = PuppetLint.configuration.ignore_paths

      puts '[' if PuppetLint.configuration.json
      path.each do |f|
        next if ignore_paths.any? { |p| File.fnmatch(p, f) }
        l = PuppetLint.new
        l.file = f
        l.run
        l.print_problems
        puts ',' if f != path.last && PuppetLint.configuration.json

        if l.errors? || (l.warnings? && PuppetLint.configuration.fail_on_warnings)
          return_val = 1
        end

        next unless PuppetLint.configuration.fix && l.problems.none? { |r| r[:check] == :syntax }
        File.open(f, 'wb') do |fd|
          fd.write(l.manifest)
        end
      end
      puts ']' if PuppetLint.configuration.json

      return return_val
    rescue PuppetLint::NoCodeError
      puts 'puppet-lint: no file specified or specified file does not exist'
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      return 1
    end
  end
end
