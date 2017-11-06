---
layout: nomenu
---

{:.page-title}
# Control Comments

Blocks of lines in your manifest can be ignored by boxing them in with
`lint:ignore:<check name>` and `lint:endignore` comments.

{% highlight puppet %}
class test {
  # lint:ignore:double_quoted_strings
  notify { "test": }
  # lint:endignore
}
{% endhighlight %}

You can also ignore just a single line by adding a trailing `lint:ignore:<check
name>` comment to the line.

{% highlight puppet %}
class test {
  notify { "test": } # lint:ignore:double_quoted_strings
}
{% endhighlight %}

Multiple checks can be ignored in a single comment by listing them with space
separators

{% highlight puppet %}
class test {
  # lint:ignore:double_quoted_strings lint:ignore:slash_comments
  notify { "test": }
  // this class is super useful
  # lint:endignore
}
{% endhighlight %}

Telling puppet-lint to ignore certaini problems won't prevent them from being
detected, they just won't be displayed (or fixed) by default. If you want to
see which problems puppet-lint is ignoring, you can add `--show-ignored` to
your puppet-lint invocation.

{% highlight console %}
$ puppet-lint --show-ignored
foo/manifests/bar.pp - IGNORED: line has more than 140 characters on line 1
{% endhighlight %}

For the sake of your memory (and your coworkers), any text in your comment
after the last `lint:ignore:<check name>` will be considered to be the reason
for ignoring the check and will be displayed when showing ignored problems.

{% highlight console %}
$ puppet-lint --show-ignored
foo/manifests/bar.pp - IGNORED: line has more than 140 characters on line 1
  there is a good reason for this
{% endhighlight %}