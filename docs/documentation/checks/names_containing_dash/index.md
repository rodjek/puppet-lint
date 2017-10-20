---
layout: check
check:
  name: names_containing_dash
  title: Names Containing Dash
  enabled: 'true'
  fix: false
---
Support for dashes in class and defined type names differs depending on the
release of Puppet you're running. To ensure compatibility on all versions,
you should avoid using dashes.

##### What you have done
{% highlight puppet %}
class foo::bar-baz {}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
class foo::bar_baz {}
{% endhighlight %}
