# Public: A puppet-lint plugin that will check for the use of top scope facts.
# For example, the fact `$facts['kernel']` should be used over
# `$::kernel`.
#
# The check only finds facts using the top-scope: ie it will find $::operatingsystem
# but not $operatingsystem. It also all top scope variables are facts.
# If you have top scope variables that aren't facts you should configure the
# linter to ignore them.
#
# You can whitelist top scope variables to ignore via the Rake task.
# You should insert the following line to your Rakefile.
# `PuppetLint.configuration.top_scope_variables = ['location', 'role']`
#
# This plugin was adopted in to puppet-lint from https://github.com/mmckinst/puppet-lint-top_scope_facts-check
# Thanks to @mmckinst, @seanmil and @alexjfisher for the original work.
TOP_SCOPE_FACTS_VAR_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

PuppetLint.new_check(:top_scope_facts) do
  def check
    whitelist = ['trusted', 'facts'] + (PuppetLint.configuration.top_scope_variables || [])
    whitelist = whitelist.join('|')
    tokens.select { |x| TOP_SCOPE_FACTS_VAR_TYPES.include?(x.type) }.each do |token|
      next unless %r{^::}.match?(token.value)
      next if %r{^::(#{whitelist})\[?}.match?(token.value)
      next if %r{^::[a-z0-9_][a-zA-Z0-9_]+::}.match?(token.value)

      notify :warning, {
        message: 'top scope fact instead of facts hash',
        line: token.line,
        column: token.column,
        token: token,
      }
    end
  end

  def fix(problem)
    problem[:token].value = "facts['" + problem[:token].value.sub(%r{^::}, '') + "']"
  end
end
