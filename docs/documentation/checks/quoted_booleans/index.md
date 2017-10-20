---
layout: check
check:
  name: quoted_booleans
  title: Quoted Booleans
  enabled: 'true'
  fix: true
---
Boolean values (`true` and `false`) behave differently when quoted (`'true'`
and `'false'`), which can lead to a fair bit of confusion. As a general rule,
you sholud never quote booleans. This is not a style issue, rather a common
mistake.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  purge => 'true',
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  purge => true,
}
{% endhighlight %}
