---
layout: default
---

## Check that your Puppet manifest conform to the style guide

### Install It!

{% highlight console %}
$ gem install puppet-lint
{% endhighlight %}

### Run It!

{% highlight console %}
$ puppet-lint --with-filename /etc/puppet/modules
foo/manifests/bar.pp: trailing whitespace found on line 1
apache/manifests/server.pp: variable not enclosed in {} on line 56
...
{% endhighlight %}

### Fix Them!

Head on over to the [checks page](/checks/) to see a description of each check
and get some help on how to clear those errors.
