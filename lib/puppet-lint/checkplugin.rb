# A class that contains and provides information for the puppet-lint checks.
# This class should not be used directly, but instead should be inherited.
#
# To define a new check, you need to create a new `PuppetLint::CheckPlugin`
# subclass that implements a `check` method (and optionally a `fix` method).
# The easiest way to do this is with the `PuppetLint.new_check` method.
#
# @example
#   PuppetLint.new_check(:check_name) do
#     def check
#       # ...
#     end
#   end
#
# @api developer
class PuppetLint::CheckPlugin
  # Initialise a new PuppetLint::CheckPlugin.
  #
  # @api private
  def initialize
    @problems = []
  end

  # Check the manifest for problems and filter out any problems that should be
  # ignored.
  #
  # @api private
  # @return [Array[Hash{Symbol => Object}]] an array of detected problems in
  #   the manifest.
  def run
    check

    @problems.each do |problem|
      next if problem[:check] == :syntax
      next unless PuppetLint::Data.ignore_overrides[problem[:check]].key?(problem[:line])

      problem[:kind] = :ignored
      problem[:reason] = PuppetLint::Data.ignore_overrides[problem[:check]][problem[:line]]
    end

    @problems
  end

  # Fix any problems the check plugin has detected.
  #
  # @api private
  # @return [Array[Hash{Symbol => Object}]] an array of detected problems in
  #   manifest.
  def fix_problems
    @problems.reject { |problem| problem[:kind] == :ignored || problem[:check] == :syntax }.each do |problem|
      next unless respond_to?(:fix)

      begin
        fix(problem)
        problem[:kind] = :fixed
      rescue PuppetLint::NoFix # rubocop:disable Lint/HandleExceptions
        # noop
      end
    end

    @problems
  end

  private

  # Provides the tokenised manifest to the check plugins.
  #
  # @api developer
  # @return [Array[PuppetLint::Lexer::Token]] an array of tokens that make up
  #   the manifest being checked..
  def tokens
    PuppetLint::Data.tokens
  end

  def add_token(index, token)
    PuppetLint::Data.insert(index, token)
  end

  def remove_token(token)
    PuppetLint::Data.delete(token)
  end

  # Public: Provides the resource titles to the check plugins.
  #
  # Returns an Array of PuppetLint::Lexer::Token objects.
  def title_tokens
    PuppetLint::Data.title_tokens
  end

  # Public: Provides positional information for any resource declarations in
  # the tokens array to the check plugins.
  #
  # Returns an Array of Hashes containing the position information.
  def resource_indexes
    PuppetLint::Data.resource_indexes
  end

  # Public: Provides positional information for any class definitions in the
  # tokens array to the check plugins.
  #
  # Returns an Array of Hashes containing the position information.
  def class_indexes
    PuppetLint::Data.class_indexes
  end

  # Public: Provides positional information for any defined type definitions in
  # the tokens array to the check plugins.
  #
  # Returns an Array of Hashes containing the position information.
  def defined_type_indexes
    PuppetLint::Data.defined_type_indexes
  end

  # Public: Provides positional information for any node definitions in the
  # tokens array to the check plugins.
  #
  # Returns an Array of Hashes containing the position information.
  def node_indexes
    PuppetLint::Data.node_indexes
  end

  # Public: Provides the expanded path of the file being analysed to check
  # plugins.
  #
  # Returns the String path.
  def fullpath
    PuppetLint::Data.fullpath
  end

  # Public: Provides the path of the file being analysed as it was provided to
  # puppet-lint to the check plugins.
  #
  # Returns the String path.
  def path
    PuppetLint::Data.path
  end

  # Public: Provides the name of the file being analysed to the check plugins.
  #
  # Returns the String file name.
  def filename
    PuppetLint::Data.filename
  end

  # Public: Provides a list of formatting tokens to the check plugins.
  #
  # Returns an Array of Symbol token types.
  def formatting_tokens
    PuppetLint::Data.formatting_tokens
  end

  # Public: Provides a list of manifest lines to the check plugins.
  #
  # Returns an Array of manifest lines.
  def manifest_lines
    PuppetLint::Data.manifest_lines
  end

  # Internal: Prepare default problem report information.
  #
  # Returns a Hash of default problem information.
  def default_info
    @default_info ||= {
      :check      => self.class.const_get('NAME'),
      :fullpath   => fullpath,
      :path       => path,
      :filename   => filename,
    }
  end

  # Public: Report a problem with the manifest being checked.
  #
  # kind    - The Symbol problem type (:warning or :error).
  # problem - A Hash containing the attributes of the problem
  #   :message - The String message describing the problem.
  #   :line    - The Integer line number of the location of the problem.
  #   :column  - The Integer column number of the location of the problem.
  #   :check   - The Symbol name of the check that detected the problem.
  #
  # Returns nothing.
  def notify(kind, problem)
    problem[:kind] = kind
    problem.merge!(default_info) { |_key, v1, _v2| v1 }

    unless [:warning, :error, :fixed].include?(kind)
      raise ArgumentError, 'unknown value passed for kind'
    end

    [:message, :line, :column, :check].each do |attr|
      unless problem.key?(attr)
        raise ArgumentError, "problem hash must contain #{attr.inspect}"
      end
    end

    @problems << problem
  end
end
