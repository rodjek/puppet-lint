# Public: Test the manifest tokens for any classes or defined types that are
# not in an appropriately named file for the autoloader to detect and record
# an error of each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#separate-files
PuppetLint.new_check(:autoloader_layout) do
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
