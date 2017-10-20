---
layout: check
check:
  name: nested_classes_or_defines
  title: Nested Classes Or Defines
  enabled: 'true'
  fix: false
  style_guide: "#nested-classes-or-defined-types"
---
Classes and defined resource types must not be defined within other classes

##### What you have done
{% highlight puppet %}
class apache {
  class ssl { }
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
# in apache/manifests/init.pp
class apache { }

# in apache/manifests/ssl.pp
class apache::ssl { }
{% endhighlight %}
