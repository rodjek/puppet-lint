---
layout: check
check:
  name: inherits_across_namespaces
  title: Inherits Across Namespaces
  enabled: 'true'
  fix: false
  style_guide: "#class-inheritance"
---
Inheritance may be used within a module, but must not be used across module
namespaces. Cross-module dependencies should be satisfied in a more portable
way that does not violate the concept of modularity, such as with `include`
statements or relationship declarations.

##### What you have done
{% highlight puppet %}
class ssh inherits server { }

class ssh::client inherits workstation { }

class wordpress inherits apache { }
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
class ssh { }

class ssh::client inherits ssh { }

class ssh::server inherits ssh { }

class ssh::server::solaris inherits ssh::server { }
{% endhighlight %}
