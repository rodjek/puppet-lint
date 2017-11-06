---
layout: nomenu
---
{:.page-title}
# Running puppet-lint with Rake

puppet-lint includes a pre-made Rake task in order to easily integrate into
your testing workflow.

To test your entire Puppet manifest directory, add the following line to your
`Rakefile`:

{% highlight ruby %}
require 'puppet-lint/tasks/puppet-lint'
{% endhighlight %}

This will add a `lint` task to your Rakefile that you can run with `rake lint`.

To modify the behaviour of the Rake task, you can define the task yourself. For
example:

{% highlight ruby %}
PuppetLint::RakeTask.new(:lint) do |config|
  # Pattern of files to check, defaults to `**/*.pp`
  config.pattern = 'modules'

  # Pattern of files to ignore
  config.ignore_paths = ['modules/apt', 'modules/stdlib']

  # List of checks to disable
  config.disable_checks = ['documentation', '140chars']

  # Don't prefix the output with the filenames
  config.with_filename = false

  # Make the task fail if there are any warnings detected
  config.fail_on_warnings = true

  # Customise the output with your own format string (see puppet-lint help
  # output for details)
  config.log_format = '%{filename} - %{message}'

  # Include context lines from the manifest for each problem
  config.with_context = true

  # Automatically fix problems
  config.fix = true

  # Show any problems that have been ignored with control comments in the
  # output.
  config.show_ignored = true

  # Compare module layout relative to the module root
  config.relative = true
end
{% endhighlight %}
