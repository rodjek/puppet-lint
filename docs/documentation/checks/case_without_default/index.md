---
layout: check
check:
  name: case_without_default
  title: Case Without Default
  enabled: 'true'
  fix: false
  style_guide: "#defaults-for-case-statements-and-selectors"
---
Case statements should have default cases. Additionally, the default case
should fail the catalogue compilation when the resulting behaviour can not be
predicted on the majority of platforms the module will be used on. If you
want the default case to be "do nothing", include it as an explicit `default:
{}` for clarity's sake.

##### What you have done
{% highlight puppet %}
case $::operatingsystem {
  centos: {
    $version = '1.2.3'
  }
  solaris: {
    $version = '3.2.1'
  }
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
case $::operatingsystem {
  centos: {
    $version = '1.2.3'
  }
  solaris: {
    $version = '3.2.1'
  }
  default: {
    fail("Module ${module_name} is not supported on ${::operatingsystem}")
  }
}
{% endhighlight %}
