# All classes and resource type definitions must be in separate files in the
# manifests directory of their module. This is functionally identical to
# declaring all classes and defines in `init.pp`, but highlights the structure
# and makes everything more legible.
#
# Additionally, the files should be named appropriately for the class or
# defined type they contain. `class foo` should be in `foo/manifests/init.pp`,
# `class foo::bar` should be in `foo/manifests/bar.pp` and so on. You can read
# more about the filesystem layout for modules in the [module fundamentals
# documentation](https://puppet.com/docs/puppet/latest/modules_fundamentals.html#module-layout).
#
# @style_guide #separate-files
# @enabled true
PuppetLint.new_check(:autoloader_layout) do
  # Test the manifest tokens for any classes or defined types that ore not in
  # an appropriately named file for the autoloader to detect, and record an
  # error for each instance found.
  def check
    return if fullpath.nil? || fullpath == ''

    (class_indexes + defined_type_indexes).each do |class_idx|
      title_token = class_idx[:name_token]
      split_title = title_token.value.split('::')
      mod = split_title.first
      expected_path = if split_title.length > 1
                        "/#{mod}/manifests/#{split_title[1..-1].join('/')}.pp"
                      else
                        "/#{title_token.value}/manifests/init.pp"
                      end

      if PuppetLint.configuration.relative
        expected_path = expected_path.gsub(%r{^/}, '').split('/')[1..-1].join('/')
      end

      next if fullpath.end_with?(expected_path)

      notify(
        :error,
        :message => "#{title_token.value} not in autoload module layout",
        :line    => title_token.line,
        :column  => title_token.column
      )
    end
  end
end
