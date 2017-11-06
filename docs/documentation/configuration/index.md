---
layout: nomenu
---
{:.page-title}
# Configuring puppet-lint

Rather than passing options and flags to puppet-lint each time you run it, you
can put these into a configuration file which will be read by puppet-lint
automatically.

Each time puppet-lint starts up, it loads configuration from the following
three files in order (if they exist).

{:.list-featured .space-bottom-20}
  * `/etc/puppet-lint.rc`
  * `$HOME/.puppet-lint.rc`
  * `./.puppet-lint.rc`

This means that a flag in a `.puppet-lint.rc` in your current working directory
will take precedence over a flag in the `.puppet-lint.rc` in your home
directory, for example. Values specified on the command line take final
precedence and override all config file options.

Any flag or option that can be specified on the command line can also be
specified in the configuration file. For example, to always disable the hard
tab character check, create a `.puppet-lint.rc` file in your home directory and
add the following line to it:

{% highlight text %}
--no-hard_tabs-check
{% endhighlight %}

Or, if you wanted to specify a limited list of checks that puppet-lint should
run, include a line like this:
{% highlight text %}
--only-checks=trailing_whitespace,hard_tabs,ensure_first_param,trailing_comma
{% endhighlight %}
