require 'puppet-lint/checkplugin'

# Internal: Various methods that orchestrate the actions of the puppet-lint
# check plugins.
class PuppetLint::Checks
  # Public: Get an Array of problem Hashes.
  attr_accessor :problems

  # Public: Initialise a new PuppetLint::Checks object.
  def initialize
    @problems = []
  end

  # Internal: Tokenise the manifest code and prepare it for checking.
  #
  # path    - The path to the file as passed to puppet-lint as a String.
  # content - The String manifest code to be checked.
  #
  # Returns nothing.
  def load_data(path, content)
    lexer = PuppetLint::Lexer.new
    PuppetLint::Data.path = path
    PuppetLint::Data.manifest_lines = content.split("\n", -1)
    begin
      PuppetLint::Data.tokens = lexer.tokenise(content)
      PuppetLint::Data.parse_control_comments
    rescue PuppetLint::LexerError => e
      message = if e.reason.nil?
                  'Syntax error'
                else
                  "Syntax error (#{e.reason})"
                end

      problems << {
        :kind     => :error,
        :check    => :syntax,
        :message  => message,
        :line     => e.line_no,
        :column   => e.column,
        :fullpath => PuppetLint::Data.fullpath,
        :path     => PuppetLint::Data.path,
        :filename => PuppetLint::Data.filename,
      }
      PuppetLint::Data.tokens = []
    end
  end

  # Internal: Run the lint checks over the manifest code.
  #
  # fileinfo - The path to the file as passed to puppet-lint as a String.
  # data     - The String manifest code to be checked.
  #
  # Returns an Array of problem Hashes.
  def run(fileinfo, data)
    load_data(fileinfo, data)

    checks_run = []
    enabled_checks.each do |check|
      klass = PuppetLint.configuration.check_object[check].new
      # FIXME: shadowing #problems
      problems = klass.run
      checks_run << [klass, problems]
    end

    checks_run.each do |klass, problems|
      if PuppetLint.configuration.fix
        @problems.concat(klass.fix_problems)
      else
        @problems.concat(problems)
      end
    end

    @problems
  rescue PuppetLint::SyntaxError => e
    @problems << {
      :kind     => :error,
      :check    => :syntax,
      :message  => 'Syntax error',
      :fullpath => File.expand_path(fileinfo, ENV['PWD']),
      :filename => File.basename(fileinfo),
      :path     => fileinfo,
      :line     => e.token.line,
      :column   => e.token.column,
    }

    @problems
  rescue => e
    $stdout.puts <<-END.gsub(%r{^ {6}}, '')
      Whoops! It looks like puppet-lint has encountered an error that it doesn't
      know how to handle. Please open an issue at https://github.com/rodjek/puppet-lint
      and paste the following output into the issue description.
      ---
      puppet-lint version: #{PuppetLint::VERSION}
      ruby version: #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}
      platform: #{RUBY_PLATFORM}
      file path: #{fileinfo}
    END

    if File.readable?(fileinfo)
      $stdout.puts [
        'file contents:',
        '```',
        File.read(fileinfo),
        '```',
      ].join("\n")
    end

    $stdout.puts [
      'error:',
      '```',
      "#{e.class}: #{e.message}",
      e.backtrace.join("\n"),
      '```',
    ].join("\n")

    exit 1
  end

  # Internal: Get a list of checks that have not been disabled.
  #
  # Returns an Array of String check names.
  def enabled_checks
    @enabled_checks ||= begin
      PuppetLint.configuration.checks.select do |check|
        PuppetLint.configuration.send("#{check}_enabled?")
      end
    end
  end

  # Internal: Render the fixed manifest.
  #
  # Returns the manifest as a String.
  def manifest
    PuppetLint::Data.tokens.map(&:to_manifest).join('')
  end
end
