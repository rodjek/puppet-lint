---
layout: nomenu
items:
  -
    anchor: whitespace
    text: Spacing, Indentation & Whitespace
    checks:
      - 
        check_name: 2sp_soft_tabs
        text: two-space soft tabs not used
      -
        check_name: hard_tabs
        text: tab character found
      -
        check_name: trailing_whitespace
        text: trailing whitespace found
      -
        check_name: 80chars
        text: line has more than 80 characters
      -
        check_name: 140chars
        text: line has more than 140 characters
      -
        check_name: arrow_alignment
        text: => is not properly aligned
  -
    anchor: comments
    text: Comments
    checks:
      -
        check_name: slash_comments
        text: // comment found
      -
        check_name: star_comments
        text: /* */ comment found
  -
    anchor: strings
    text: Quoting
    checks:
      -
        check_name: double_quoted_strings
        text: double quoted string containing no variables
      -
        check_name: variables_not_enclosed
        text: variable not enclosed in {}
      -
        check_name: only_variable_string
        text: string containing only a variable
      -
        check_name: single_quote_string_with_variables
        text: single quoted string containing a variable found
      -
        check_name: quoted_booleans
        text: quoted boolean value found
      -
        check_name: puppet_url_without_modules
        text: puppet:// URL without modules/ found
  -
    anchor: resources
    text: Resources
    checks:
      -
        check_name: unquoted_resource_title
        text: unquoted resource title
      -
        check_name: ensure_first_param
        text: ensure found on line but it's not the first attribute
      -
        check_name: ensure_not_symlink_target
        text: symlink target specified in ensure attr
      -
        check_name: file_mode
        text: mode should be represented as a 4 digit octal value or symbolic mode
      -
        check_name: unquoted_file_mode
        text: unquoted file mode
      -
        check_name: duplicate_params
        text: duplicate parameter found in resource
  -
    anchor: conditional
    text: Conditionals
    checks:
      -
        check_name: selector_inside_resource
        text: selector inside resource block
      -
        check_name: case_without_default
        text: case statement without a default case
  -
    anchor: class
    text: Classes
    checks:
      -
        check_name: autoloader_layout
        text: not in autoload module layout
      -
        check_name: right_to_left_relationship
        text: right-to-left (<-) relationship
      -
        check_name: nested_classes_or_defines
        text: class defined inside a class
      -
        check_name: nested_classes_or_defines
        text: define defined inside a class
      -
        check_name: inherits_across_namespaces
        text: class inherits across namespaces
      -
        check_name: parameter_order
        text: optional parameter listed before required parameter
      -
        check_name: class_inherits_from_params_class
        text: class inheriting from params class
      -
        check_name: name_contains_dash
        text: contains a dash
      -
        check_name: arrow_on_right_operand_line
        text: arrow should be on right operand's line
  -
    anchor: variables
    text: Variables
    checks:
      -
        check_name: variable_is_lowercase
        text: variable is lowercase
      -
        check_name: variable_contains_dash
        text: variable contains a dash
      -
        check_name: variable_scope
        text: top-scope variable being used without an explicit namespace
  -
    anchor: documentation
    text: Documentation
    checks:
      -
        check_name: documentation
        text: not documented
  -
    anchor: nodes
    text: Nodes
    checks:
      -
        check_name: unquoted_node_name
        text: unquoted node name found
---
{:.page-title}
# Checks
<div class="spacer">&nbsp;</div>

{% for checkclass in page.items %}
{:.section-title id="{{ checkclass.anchor }}"}
## {{ checkclass.text }}
<div class="spacer">&nbsp;</div>
<ul class="list-featured space-bottom-20">
{% for check in checkclass.checks %}
  <li><a href="/documentation/checks/{{ check.check_name }}/">"{{ check.text }}"</a></li>
{% endfor %}
</ul>
{% endfor %}
