---
layout: default
---
# Control Comments

---

Blocks of lines in your manifest can be ignored by boxing them in with
`lint:ignore:<check name>` and `lint:endignore` comments

{% highlight puppet %}
class foo {
  $bar = 'bar'
  # lint:ignore:double_quoted_strings
  $baz = "baz"
  $gronk = "gronk"
  # lint:endignore
}
{% endhighlight %}

You can also ignore just a single line by adding a trailing `lint:ignore:<check
name>` comment to the line

{% highlight puppet %}
$this_line_has_a_really_long_name_and_value = "[snip]" # lint:ignore:80chars
{% endhighlight %}

Telling puppet-lint to ignore certain problems won't prevent them from being
detected, they just won't be displayed (or fixed) by default.  If you want to
see which problems puppet-lint is ignoring, you can add `--show-ignored` to your
puppet-lint invocation.

{% highlight console %}
$ puppet-lint --show-ignored
foo/manifests/bar.pp - IGNORED: line has more than 80 characters on line 1
{% endhighlight %}

For the sake of your memory (and your coworkers), any text in your comment
after `lint:ignore:<check name>` will be considered the reason for ignoring the
check and will be displayed when showing ignored problems.

{% highlight console %}
$ puppet-lint --show-ignored
foo/manifests/bar.pp - IGNORED: line has more than 80 characters on line 1
  there is a good reason for this
{% endhighlight %}
