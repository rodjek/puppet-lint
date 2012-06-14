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
    @default_info = {:check => 'unknown', :linenumber => 0}
  end

  def register_check(check)
    @checks << check
  end

  #     notify(kind, message_hash)    #=> nil
  #
  # Adds the message to the problems array.
  # The _kind_ gets added to the _message_hash_ by setting the key :_kind_.
  # Typically, the _message_hash_ should contain following keys:
  # <i>message</i>::     which contains a string value describing the problem
  # <i>linenumber</i>::  which contains the line number on which the problem occurs.
  # Besides the :_kind_ value that is being set, some other key/values are also
  # added. Typically, this is
  # <i>check</i>::      which contains the name of the check that is being executed.
  # <i>linenumber</i>:: which defaults to 0 if the message does not already contain one.
  #
  #     notify :warning, :message => "Something happened", :linenumber => 4
  #     => {:kind=>:warning, :message=>"Something happened", :linenumber=>4, :check=>'unknown'}
  #
  def notify(kind, message_hash)
    message_hash[:kind] = kind
    message_hash.merge!(@default_info) {|key, v1, v2| v1 }
    @problems << message_hash
    message_hash
  end

  def run(fileinfo, data)
    lexer = Puppet::Parser::Lexer.new
    lexer.string = data
    @tokens = lexer.fullscan
    @fileinfo = fileinfo
    @data = data

    self.public_methods.select { |method|
      method.to_s.start_with? 'lint_check_'
    }.each { |method|
      name = method.to_s[11..-1]
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
              if @tokens[token_idx].first == :CLASS and @tokens[token_idx + 1].first != :LBRACE
                @class_indexes << {:start => token_idx, :end => idx}
              end
              @defined_type_indexes << {:start => token_idx, :end => idx} if @tokens[token_idx].first == :DEFINE
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
    @fileinfo[:path]
  end

  def fullpath
    @fileinfo[:fullpath]
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

  def self.check(name, default_enabled = true, &b)
    PuppetLint.configuration.add_check name, default_enabled
    define_method("lint_check_#{name}", b)
  end
end

