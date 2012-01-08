class PuppetLint
  module Plugin
    module ClassMethods
      def repository
        @repository ||= []
      end

      def inherited(klass)
        repository << klass
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end

class PuppetLint::CheckPlugin
  include PuppetLint::Plugin
  attr_reader :problems, :checks

  def initialize
    @problems = []
    @checks = []
    @default_info = {:check => '', :linenumber => 0}
  end

  def register_check(check)
    @checks << check
  end

  def notify(kind, message)
    message[:kind] = kind
    @problems << message.merge!(@default_info) {|key, v1, v2| v1 }
  end

  def run(path, data)
    lexer = Puppet::Parser::Lexer.new
    lexer.string = data
    @tokens = lexer.fullscan
    @path = path
    @data = data

    test(path, data) if self.respond_to? :test
    self.public_methods.select { |method|
      method.start_with? 'lint_check_'
    }.each { |method|
      name = method[11..-1]
      @default_info[:check] = name
      self.send(method) if PuppetLint.configuration.send("#{name}_enabled?")
    }

    @problems
  end

  def filter_tokens
    @title_tokens = []
    @resource_indexes = []
    @class_indexes = []
    @defined_type_indexes = []

    @tokens.each_index do |token_idx|
      if @tokens[token_idx].first == :COLON
        # gather a list of tokens that are resource titles
        if @tokens[token_idx-1].first == :RBRACK
          title_array_tokens = @tokens[@tokens.rindex { |r| r.first == :LBRACK }+1..token_idx-2]
          @title_tokens += title_array_tokens.select { |token| [:STRING, :NAME].include? token.first }
        else
          if @tokens[token_idx + 1].first != :LBRACE
            @title_tokens << @tokens[token_idx-1]
          end
        end

        # gather a list of start and end indexes for resource attribute blocks
        if @tokens[token_idx+1].first != :LBRACE
          @resource_indexes << {:start => token_idx+1, :end => @tokens[token_idx+1..-1].index { |r| [:SEMIC, :RBRACE].include? r.first }+token_idx}
        end
      elsif [:CLASS, :DEFINE].include? @tokens[token_idx].first
        lbrace_count = 0
        @tokens[token_idx+1..-1].each_index do |class_token_idx|
          idx = class_token_idx + token_idx
          if @tokens[idx].first == :LBRACE
            lbrace_count += 1
          elsif @tokens[idx].first == :RBRACE
            lbrace_count -= 1
            if lbrace_count == 0
              class_indexes << {:start => token_idx, :end => idx} if @tokens[token_idx].first == :CLASS
              defined_type_indexes << {:start => token_idx, :end => idx} if @tokens[token_idx].first == :DEFINE
              break
            end
          end
        end
      end
    end
  end

  def tokens
    @tokens
  end

  def path
    @path
  end

  def data
    @data
  end

  def title_tokens
    filter_tokens if @title_tokens.nil?
    @title_tokens
  end

  def resource_indexes
    filter_tokens if @resource_indexes.nil?
    @resource_indexes
  end

  def class_indexes
    filter_tokens if @class_indexes.nil?
    @class_indexes
  end

  def defined_type_indexes
    filter_tokens if @defined_type_indexes.nil?
    @defined_type_indexes
  end

  def manifest_lines
    @manifest_lines ||= @data.split("\n")
  end

  def self.check(name, &b)
    PuppetLint.configuration.add_check name
    define_method("lint_check_#{name}", b)
  end
end

