---
layout: check
check:
  name: parameter_order
  title: Parameter Order
  enabled: 'true'
  fix: false
  style_guide: "#display-order-of-parameters"
---
In parameterized class and defined type declarations, parameters that are
required should be listed before optional parameters (i.e. parameters with
default values).

##### What you have done
{% highlight puppet %}
class ntp(
  $options = 'iburst',
  $servers,
  $multicast = false,
) {}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
class ntp(
  $servers,
  $multicast = false,
  $options   = 'iburst',
) { }
{% endhighlight %}
