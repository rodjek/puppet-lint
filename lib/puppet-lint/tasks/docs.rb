require 'rake'

class PuppetLint
  PROJECT_ROOT = File.expand_path('../../../..', __FILE__)

  module Docs
    class Check
      attr_reader :yard_obj

      def initialize(yard_obj)
        @yard_obj = yard_obj
      end

      def name
        yard_obj.name.to_s
      end

      def page_title
        if yard_obj.tag('title')
          yard_obj.tag('title').text
        else
          name.split('_').map(&:capitalize).join(' ')
        end
      end

      def supports_fix?
        PuppetLint.configuration.check_object[name.to_sym].new.respond_to?(:fix)
      end

      def style_guide_link
        yard_obj.tag('style_guide').text if yard_obj.tag('style_guide')
      end
      alias_method :style_guide?, :style_guide_link

      def deprecation_message
        yard_obj.tag('deprecated').text if yard_obj.tag('deprecated')
      end
      alias_method :deprecated?, :deprecation_message

      def frontmatter
        frontmatter = {
          'layout' => 'check',
          'check'  => {
            'name'        => name,
            'title'       => page_title,
            'enabled'     => yard_obj.tag('enabled').text,
            'fix'         => supports_fix?,
          },
        }

        frontmatter['check']['style_guide'] = style_guide_link if style_guide?

        frontmatter
      end

      def doc_file
        @doc_file ||= Pathname.new(File.join(PuppetLint::PROJECT_ROOT, 'docs', 'documentation', 'checks', name, 'index.md'))
      end

      def documentation
        yard_obj.docstring
      end

      def write
        doc_file.dirname.mkpath

        doc_file.open('w') do |f|
          f.puts YAML.dump(frontmatter)
          f.puts '---'

          if deprecated?
            f.puts "{% include deprecation.html message=\"#{deprecation_message}\" %}"
          end

          f.puts documentation

          yard_obj.tags('example').each do |example|
            f.puts "\n##### #{example.name}"
            f.puts '{% highlight puppet %}'
            f.puts example.text
            f.puts '{% endhighlight %}'
          end
        end
      end
    end
  end
end

namespace :docs do
  task :generate do
    require 'yard'
    require 'yaml'
    require 'pathname'
    require File.join(PuppetLint::PROJECT_ROOT, '.yard.rb')

    YARD.parse(File.join(PuppetLint::PROJECT_ROOT, 'lib', 'puppet-lint', 'plugins', '**', '*.rb'))
    YARD::Registry.all(:puppet_lint_check).each do |yard_obj|
      check = PuppetLint::Docs::Check.new(yard_obj)
      check.write
    end
  end
end
