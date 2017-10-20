---
layout: nomenu
---

# Check that your Puppet manifests conform to the style guide

{:.section-title}
## Install It!
<div class="spacer">&nbsp;</div>

{% highlight command %}
$ gem install puppet-lint
{% endhighlight %}

{:.section-title}
## Run It!
<div class="spacer">&nbsp;</div>

{% highlight command %}
$ puppet-lint /etc/puppet/modules
foo/manifests/bar.pp - ERROR: trailing whitespace found on line 1
apache/manifests/server.pp - WARNING: variable not enclosed in {} on line 56
{% endhighlight %}

{:.section-title}
## Fix It!
<div class="spacer">&nbsp;</div>

{% highlight command %}
$ puppet-lint --fix /etc/puppet/modules
foo/manifests/bar.pp - FIXED: trailing whitespace found on line 1
apache/manifests/server.pp - FIXED: variable not enclosed in {} on line 56
{% endhighlight %}
