unless String.respond_to?('prepend')
  class String
    def prepend(lead)
      self.replace "#{lead}#{self}"
    end
  end
end
