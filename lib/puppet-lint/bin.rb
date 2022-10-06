require 'pathname'
require 'uri'
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
      full_path = File.expand_path(path, ENV['PWD'])
      full_base_path = if File.directory?(full_path)
                         full_path
                       else
                         File.dirname(full_path)
                       end

      full_base_path_uri = if full_base_path.start_with?('/')
                             'file://' + full_base_path
                           else
                             'file:///' + full_base_path
                           end

      full_base_path_uri += '/' unless full_base_path_uri.end_with?('/')

      path = path.gsub(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
      path = if File.directory?(path)
               Dir.glob("#{path}/**/*.pp")
             else
               @args
             end

      PuppetLint.configuration.with_filename = true if path.length > 1

      return_val = 0
      ignore_paths = PuppetLint.configuration.ignore_paths
      all_problems = []

      path.each do |f|
        next if ignore_paths.any? { |p| File.fnmatch(p, f) }
        l = PuppetLint.new
        l.file = f
        l.run
        all_problems << l.print_problems

        if l.errors? || (l.warnings? && PuppetLint.configuration.fail_on_warnings)
          return_val = 1
        end

        next unless PuppetLint.configuration.fix && l.problems.none? { |r| r[:check] == :syntax }
        File.open(f, 'wb') do |fd|
          fd.write(l.manifest)
        end
      end

      if PuppetLint.configuration.sarif
        report_sarif(all_problems, full_base_path, full_base_path_uri)
      elsif PuppetLint.configuration.json
        all_problems.each do |problems|
          problems.each do |problem|
            problem.delete_if { |key, _| [:description, :help_uri].include?(key) }
          end
        end
        puts JSON.pretty_generate(all_problems)
      end

      return_val
    rescue PuppetLint::NoCodeError
      puts 'puppet-lint: no file specified or specified file does not exist'
      puts "puppet-lint: try 'puppet-lint --help' for more information"
      1
    end
  end

  # Internal: Print the reported problems in SARIF format to stdout.
  #
  # problems - An Array of problem Hashes as returned by
  #            PuppetLint::Checks#run.
  #
  # Returns nothing.
  def report_sarif(problems, base_path, base_path_uri)
    sarif_file = File.read(File.join(__dir__, 'report', 'sarif_template.json'))
    sarif = JSON.parse(sarif_file)
    sarif['runs'][0]['originalUriBaseIds']['ROOTPATH']['uri'] = base_path_uri
    rules = sarif['runs'][0]['tool']['driver']['rules'] = []
    results = sarif['runs'][0]['results'] = []
    problems.each do |messages|
      messages.each do |message|
        relative_path = Pathname.new(message[:fullpath]).relative_path_from(Pathname.new(base_path))
        rules = sarif['runs'][0]['tool']['driver']['rules']
        rule_exists = rules.any? { |r| r['id'] == message[:check] }
        unless rule_exists
          new_rule = { 'id' => message[:check] }
          new_rule['fullDescription'] = { 'text' => message[:description] } unless message[:description].nil?
          new_rule['fullDescription'] = { 'text' => 'Check for any syntax error and record an error of each instance found.' } if new_rule['fullDescription'].nil? && message[:check] == :syntax
          new_rule['defaultConfiguration'] = { 'level' => message[:KIND].downcase } if ['error', 'warning'].include?(message[:KIND].downcase)
          new_rule['helpUri'] = message[:help_uri] unless message[:help_uri].nil?
          rules << new_rule
        end
        rule_index = rules.index { |r| r['id'] == message[:check] }
        result = {
          'ruleId' => message[:check],
          'ruleIndex' => rule_index,
          'message' => { 'text' => message[:message] },
          'locations' => [{ 'physicalLocation' => { 'artifactLocation' => { 'uri' => relative_path, 'uriBaseId' => 'ROOTPATH' },
'region' => { 'startLine' => message[:line], 'startColumn' => message[:column] } } }],
        }
        results << result
      end
    end
    puts JSON.pretty_generate(sarif)
  end
end
