---
layout: check
check:
  name: names_containing_uppercase
  title: Names Containing Uppercase
  enabled: 'true'
  fix: true
  style_guide: https://docs.puppet.com/puppet/latest/reference/modules_fundamentals.html#allowed-module-names
---
Module, class and defined type names should not contain uppercase characters.

##### What you have done
{% highlight puppet %}
class SSH { }
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
class ssh { }
{% endhighlight %}
