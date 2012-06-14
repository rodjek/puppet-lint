# To change this template, choose Tools | Templates
# and open the template in the editor.

class PuppetLint::Plugins::CheckDebug < PuppetLint::CheckPlugin

  check 'debug', false do
    puts "------------------ data ------------------"
    p @data
    puts "----------------- tokens ------------------"
    p @tokens
    puts "----------------- manifest_lines ------------------"
    p manifest_lines
    puts "----------------- title_tokens ------------------"
    p title_tokens
    puts "----------------- resource_indexes ------------------"
    p resource_indexes
    puts "----------------- class_indexes ------------------"
    p class_indexes
    puts "----------------- defined_type_indexes ------------------"
    p defined_type_indexes
  end

end
