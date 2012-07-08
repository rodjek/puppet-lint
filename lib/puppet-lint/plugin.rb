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
    lexer = PuppetLint::Lexer.new
    @tokens = lexer.tokenise(data)
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

    @tokens.each_index do |token_idx|
      if @tokens[token_idx].type == :COLON
        # gather a list of tokens that are resource titles
        if @tokens[token_idx-1].type == :RBRACK
          title_array_tokens = @tokens[@tokens.rindex { |r| r.type == :LBRACK }+1..token_idx-2]
          @title_tokens += title_array_tokens.select { |token| [:STRING, :NAME].include? token.type }
        else
          if @tokens[token_idx + 1].type != :LBRACE
            @title_tokens << @tokens[token_idx-1]
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

  # Internal: Calculate the positions of all resource declarations within the
  # tokenised manifest.  These positions only point to the content of the
  # resource declaration, they do not include resource types or
  # titles/namevars.
  #
  # Returns an Array of Hashes, each containing:
  #   :start - An Integer position in the `tokens` Array pointing to the first
  #            Token of a resource declaration parameters (type :LBRACE).
  #   :end   - An Integer position in the `tokens` Array pointing to the last
  #            Token of a resource declaration parameters (type :RBRACE).
  def resource_indexes
    @resource_indexes ||= Proc.new do
      result = []
      tokens.each_index do |token_idx|
        if tokens[token_idx].type == :COLON
          if tokens[token_idx + 1].type != :LBRACE
            end_idx = tokens[(token_idx + 1)..-1].index { |r|
              [:SEMIC, :RBRACE].include? r.type
            } + token_idx

            result << {:start => token_idx + 1, :end => end_idx}
          end
        end
      end
      result
    end.call
  end

  # Internal: Calculate the positions of all class definitions within the
  # tokenised manifest.
  #
  # Returns an Array of Hashes, each containing:
  #   :start - An Integer position in the `tokens` Array pointing to the first
  #            token of a class (type :CLASS).
  #   :end   - An Integer position in the `tokens` Array pointing to the last
  #            token of a class (type :RBRACE).
  def class_indexes
    @class_indexes ||= Proc.new do
      result = []
      tokens.each_index do |token_idx|
        if tokens[token_idx].type == :CLASS
          depth = 0
          tokens[token_idx+1..-1].each_index do |class_token_idx|
            idx = class_token_idx + token_idx + 1
            if tokens[idx].type == :LBRACE
              depth += 1
            elsif tokens[idx].type == :RBRACE
              depth -= 1
              if depth == 0
                if tokens[token_idx..-1].reject { |r|
                  r.type == :WHITESPACE
                }[1].type != :LBRACE
                  result << {:start => token_idx, :end => idx}
                end
                break
              end
            end
          end
        end
      end
      result
    end.call
  end

  # Internal: Calculate the positions of all defined type definitions within
  # the tokenised manifest.
  #
  # Returns an Array of Hashes, each containing:
  #   :start - An Integer position in the `tokens` Array pointing to the first
  #            token of a defined type (type :DEFINE).
  #   :end   - An Integer position in the `tokens` Array pointing to the last
  #            token of a defined type (type :RBRACE).
  def defined_type_indexes
    @defined_type_indexes ||= Proc.new do
      result = []
      tokens.each_index do |token_idx|
        if tokens[token_idx].type == :DEFINE
          depth = 0
          tokens[token_idx+1..-1].each_index do |define_token_idx|
            idx = define_token_idx + token_idx + 1
            if tokens[idx].type == :LBRACE
              depth += 1
            elsif tokens[idx].type == :RBRACE
              depth -= 1
              if depth == 0
                result << {:start => token_idx, :end => idx}
                break
              end
            end
          end
        end
      end
      result
    end.call
  end

  def manifest_lines
    @manifest_lines ||= @data.split("\n")
  end

  def self.check(name, &b)
    PuppetLint.configuration.add_check name
    define_method("lint_check_#{name}", b)
  end
end

