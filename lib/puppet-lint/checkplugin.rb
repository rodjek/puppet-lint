class PuppetLint::CheckPlugin
  def initialize
    @problems = []
  end

  def run
    check

    if PuppetLint.configuration.fix && self.respond_to?(:fix)
      @problems.each do |problem|
        begin
          fix(problem)
        rescue PuppetLint::NoFix
          # do nothing
        else
          problem[:kind] = :fixed
        end
      end
    end

    @problems
  end

  private

  def tokens
    PuppetLint::Data.tokens
  end

  def title_tokens
    PuppetLint::Data.title_tokens
  end

  def resource_indexes
    PuppetLint::Data.resource_indexes
  end

  def class_indexes
    PuppetLint::Data.class_indexes
  end

  def defined_type_indexes
    PuppetLint::Data.defined_type_indexes
  end

  def fullpath
    PuppetLint::Data.fullpath
  end

  def path
    PuppetLint::Data.path
  end

  def filename
    PuppetLint::Data.filename
  end

  def formatting_tokens
    PuppetLint::Data.formatting_tokens
  end

  def manifest_lines
    PuppetLint::Data.manifest_lines
  end

  def default_info
    @default_info ||= {
      :check      => self.class.const_get('NAME'),
      :linenumber => 0,
      :column     => 0,
      :fullpath   => fullpath,
      :path       => path,
      :filename   => filename,
    }
  end

  # Public: Report a problem with the manifest being checked.
  #
  # kind    - The Symbol problem type (:warning or :error).
  # problem - A Hash containing the attributes of the problem
  #   :message    - The String message describing the problem.
  #   :linenumber - The Integer line number of the location of the problem.
  #   :column     - The Integer column number of the location of the problem.
  #   :check      - The Symbol name of the check that detected the problem.
  #
  # Returns nothing.
  def notify(kind, problem)
    problem[:kind] = kind
    problem.merge!(default_info) { |key, v1, v2| v1 }
    @problems << problem
  end
end
