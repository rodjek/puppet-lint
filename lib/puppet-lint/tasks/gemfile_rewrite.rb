require 'parser/current'

# Simple rewriter using whitequark/parser that rewrites the "gem 'puppet-lint'"
# entry in the module's Gemfile (if present) to instead use the local
# puppet-lint working directory.
class GemfileRewrite < Parser::TreeRewriter
  def on_send(node)
    _, method_name, *args = *node

    if method_name == :gem
      gem_name = args.first
      if gem_name.type == :str && gem_name.children.first == 'puppet-lint'
        puppet_lint_root = File.expand_path(File.join(__FILE__, '..', '..', '..', '..'))
        replace(node.location.expression, "gem 'puppet-lint', :path => '#{puppet_lint_root}'")
      end
    end

    super
  end
end
