unless String.respond_to?('prepend')
  # Internal: Monkey patching String.
  class String
    # Internal: Prepends a String to self.
    #
    # lead - The String to prepend self with.
    #
    # Returns a String which is lead and self concatenated.
    def prepend(lead)
      self.replace "#{lead}#{self}"
    end
  end
end
