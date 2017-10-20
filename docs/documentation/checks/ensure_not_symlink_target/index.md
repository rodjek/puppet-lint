---
layout: check
check:
  name: ensure_not_symlink_target
  title: Ensure Not Symlink Target
  enabled: 'true'
  fix: true
  style_guide: "#symbolic-links"
---
In the interest of clarity, symbolic links should be declared by using an
ensure value of `ensure => link` and explicitly specifying a value for the
`target` attribute. Using a path to the target as the ensure value is not
recommended.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  ensure => '/tmp/bar',
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  ensure => link,
  target => '/tmp/bar',
}
{% endhighlight %}
