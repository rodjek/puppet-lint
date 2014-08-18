---
layout: default
title: unquoted_node_name
---

# Unquoted Node Name

---

Node names should be one of the following:

 * A quoted string
 * The bare word `default`
 * A regular expression

#### What you have done
{% highlight text %}
node server1 {
}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
node 'server1' {
}
{% endhighlight %}

## Disabling the check

To disable this check you can add `--no-{{ page.title }}-check` to your
`puppet-lint` command line.

{% highlight console %}
$ puppet-lint --no-{{ page.title }}-check path/to/file.pp
{% endhighlight %}

Alternatively, if you're calling puppet-lint via the Rake task, you should
insert the following line to your `Rakefile`.

{% highlight ruby %}
PuppetLint.configuration.send('disable_{{ page.title}}')
{% endhighlight %}
