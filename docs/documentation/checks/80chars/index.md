---
layout: check
check:
  name: 80chars
  title: 80chars
  enabled: 'false'
  fix: false
  style_guide: "#spacing-indentation-and-whitespace"
---
{% include deprecation.html message="The style guide has been updated with a maximum line length of
140 characters, so this check has been deprecated in favour of the
`140chars` check." %}
Your manifests should not contain any lines longer than 80 characters.
