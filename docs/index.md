---
layout: default
---

## Check that your Puppet manifest conform to the style guide

### Install It!

{% highlight puppet %}
package { 'puppet-lint':
  ensure   => '1.1.0',
  provider => 'gem',
}
{% endhighlight %}

Or, if you really must:

{% highlight console %}
$ gem install puppet-lint
{% endhighlight %}

### Run It!

{% highlight console %}
$ puppet-lint /etc/puppet/modules
foo/manifests/bar.pp - ERROR: trailing whitespace found on line 1
apache/manifests/server.pp - WARNING: variable not enclosed in {} on line 56
...
{% endhighlight %}

### Fix Them!

{% highlight console %}
$ puppet-lint --fix /etc/puppet/modules
foo/manifests/bar.pp - FIXED: trailing whitespace found on line 1
apache/manifests/server.pp - FIXED: variable not enclosed in {} on line 56
...
{% endhighlight %}

Head on over to the [checks page](/checks/) to see a description of each check
and get some help on how to clear those errors.
