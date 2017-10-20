---
layout: check
check:
  name: variable_scope
  title: Variable Scope
  enabled: 'true'
  fix: false
  style_guide: "#namespacing-variables"
---
When using top-scope variables, including facts, Puppet modules should
explicity specify the empty namespace to prevent accidental scoping issues.

##### What you have done
{% highlight puppet %}
$operatingsystem
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
$::operatingsystem
{% endhighlight %}
