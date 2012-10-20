# If we are using an older ruby version, we back-port the basic functionality
# we need for formatting output: 'somestring' % <hash>
begin
  if ('%{test}' % {:test => 'replaced'} == 'replaced')
    # If this works, we are all good to go.
  end
rescue
  # If the test failed (threw a error), monkeypatch String.
  # Most of this code came from http://www.ruby-forum.com/topic/144310 but was
  # simplified for our use.

  # Basic implementation of 'string' % { } like we need it. needs work.
  class String
    Percent = instance_method '%' unless defined? Percent
    def % *a, &b
      a.flatten!

      string = case a.last
      when Hash
        expand a.pop
      else
        self
      end

      if a.empty?
        string
      else
        Percent.bind(string).call(a, &b)
      end

    end
    def expand! vars = {}
      loop do
        changed = false
        vars.each do |var, value|
          var = var.to_s
          var.gsub! %r/[^a-zA-Z0-9_]/, ''
          [
            %r/\%\{#{ var }\}/,
          ].each do |pat|
            changed = gsub! pat, "#{ value }"
          end
        end
        break unless changed
      end
      self
    end
    def expand opts = {}
      dup.expand! opts
    end
  end
end
