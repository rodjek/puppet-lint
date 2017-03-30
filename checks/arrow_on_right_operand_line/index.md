---
layout: default
title: arrow_on_right_operand_line
sg: https://docs.puppet.com/puppet/4.9/style_guide.html#chaining-arrow-syntax
---

# Chaining arrow on the right hand operand's line

---

A chain operator should appear on the same line as its right-hand operand
([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
Service['httpd'] ->
Package['httpd']
{% endhighlight %}

#### What you should have done:
{% highlight text %}
Package['httpd']
-> Service['httpd']
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
