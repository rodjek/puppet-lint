require 'yard'
require './.yard.rb'
require 'puppet-lint'
require 'pathname'
require 'yaml'

YARD.parse("lib/puppet-lint/plugins/**/*.rb")
YARD::Registry.all(:puppet_lint_check).each do |check|
path = check.files.first.first

#p check.name
#File.basename(File.dirname(path))
doc_file = Pathname.new(File.join('docs', 'documentation', 'checks', check.name.to_s, 'index.md'))
doc_file.dirname.mkpath

frontmatter = {
  'layout' => 'check',
  'check'  => {
    'name' => check.name.to_s,
    'title' => check.tag('title').nil? ? check.name.to_s.split('_').map(&:capitalize).join(' ') : check.tag('title').text,
    'enabled'   => check.tag('enabled').text,
    'fix' => PuppetLint.configuration.check_object[check.name.to_sym].new.respond_to?(:fix),
  }
}

if check.tag('style_guide')
  frontmatter['check']['style_guide'] = check.tag('style_guide').text
end

doc_file.open('w') do |f|
  f.puts(YAML.dump(frontmatter))
  f.puts('---')

  if check.tag('deprecated')
    f.puts "{% include deprecation.html message=\"#{check.tag('deprecated').text}\" %}"
  end

  f.puts(check.docstring)
  check.tags('example').each do |example|
    f.puts "\n##### #{example.name}"
    f.puts "{% highlight puppet %}"
    f.puts example.text
    f.puts "{% endhighlight %}\n"
  end
end
end
