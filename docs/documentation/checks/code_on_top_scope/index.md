---
layout: check
check:
  name: code_on_top_scope
  title: Code On Top Scope
  enabled: 'false'
  fix: false
---
{% include deprecation.html message="While keeping all your resources inside classes or defined types
is considered a good practice, this is not mentioned in the style guide and
so this check has been deprecated and will be moved into a separate plugin
in the future." %}
It is a good practice to avoid putting resources in the top scope (outside of
any classes or defined types) as it can lead to unexpected behaviour. If you
need to ensure that a resource is defined on all hosts, it's better to
explicitly put it in the `default` node manifest.
