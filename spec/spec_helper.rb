require 'rspec/autorun'
require 'puppet-lint'

module RSpec
  module LintExampleGroup
    def subject
      klass = PuppetLint::Checks.new
      fileinfo = {}
      fileinfo[:fullpath] = self.respond_to?(:fullpath) ? fullpath : ''
      klass.load_data(fileinfo, code)
      klass.send("lint_check_#{self.class.top_level_description}")
      klass
    end
  end
end

RSpec.configure do |c|
  c.mock_framework = :rspec
  c.include RSpec::LintExampleGroup, :type => :lint, :example_group => {
    :file_path => Regexp.compile(%w{spec puppet-lint plugins}.join('[\\\/]'))
  }
end

#class PuppetLint::Warning < Exception; end
#class PuppetLint::Error < Exception; end
#PuppetLint::CheckPlugin.any_instance.stub(:warn) do |arg|
#  raise PuppetLint::Warning
#end

#PuppetLint::CheckPlugin.any_instance.stub(:error) do |arg|
#  raise PuppetLint::Error
#end

#     filter_array_of_hashes(array, filter) -> an_array
#
# Filters out hashes by applying filter_hash to each hash
# in the array. All set value/key pairs in filter_hash must
# match before a hash is allowed.
# Returns all hashes that matched in an array.
#
#   filter_array_of_hashes(
#     [
#       {:filter => 1, :name => 'one'},
#       {:filter => 2, :name => 'two'},
#       {:filter => 3, :name => 'three'},
#     ],
#     { :filter => 2 }
#   )
#   => [{:filter=>2, :name=>"two"}]
#
#   filter_array_of_hashes([{:f => 1}, {:f => 2}], {})
#   => [{:f=>1}, {:f=>2}]
#
def filter_array_of_hashes(array_of_hashes, filter_hash)
  array_of_hashes.select { |hash_to_check|
    val = true
    filter_hash.each do |k,v|
      if ! hash_to_check.key?(k)
        val = false
        break
      elsif hash_to_check[k].to_s != v.to_s
        val = false
        break
      end
    end
    val
  }
end

RSpec::Matchers.define :have_problem do |filter|

  match do |problems|
    filter_array_of_hashes(problems, filter).length > 0
  end

  failure_message_for_should do |problems|
    message = "could not find any problems matching the filter."
    message << "
    * filter = #{filter.inspect}
    * problems = [
    "
    problems.each { |prob| message << "    #{prob.inspect}," }
    message << "
      ]"
    message
  end

  failure_message_for_should_not do |problems|
    message = "some problems matched the filter."
    message << "
    * filter = #{filter.inspect}
    * matched = [
    "
    filter_array_of_hashes(problems, filter).each { |prob| message << "    #{prob.inspect}," }
    message << "
      ]"
    message
  end

end

RSpec::Matchers.define :only_have_problem do |filter|

  match do |actual|
    res = filter_array_of_hashes(actual, filter)
    res.length == actual.length && res.length == 1
  end

  failure_message_for_should do |problems|
    filtered_problems = filter_array_of_hashes(actual, filter)
    if filtered_problems.length > 1
      message = "Multiple problems found matching the filter."
    else
      left = problems - filter_array_of_hashes(actual, filter)
      message = "There were problems not matching filter."
      message << "
      * filter = #{filter.inspect}
      * unmatched = [
      "
      left.each { |prob| message << "    #{prob.inspect}," }
      message << "
        ]"
    end
    message
  end

  failure_message_for_should_not do |problems|
    message = "There were no problems found besides the ones matched with filter."
    message << "
    * filter = #{filter.inspect}
    "
    message
  end

end

