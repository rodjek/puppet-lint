---
layout: default
---
# Check API

## What you need to implement

To define a new check, you need to create a new `PuppetLint::CheckPlugin`
subclass with a `check` method and an optional `fix` method.  The easiest way
to do this is with the following:

{% highlight ruby %}
PuppetLint.new_check(:check_name) do
  def check
    # ...
  end
end
{% endhighlight %}

### check

In your check class (see above), you must define a `check` method that uses the
`notify` method (see below) to report problems in the manifest.  You can use
any of the methods listed in the "What you can use" section below to inspect
the manifest.

For a more complete example of writing a `check` method please
read the [tutorial](/developer/tutorial/).

### fix

In your check class (see above), you can define a `fix` method that will be
called on every problem submitted by the `notify` method in your `check`
method.  Your `fix` method must take one parameter and will be passed the Hash
submitted with `notify` in your `check` method.

In your `fix` method, you should make your changes to the manifest by modifying
the `tokens` Array.  If you need to back out of the `fix` method for whatever
reason, raise a `PuppetLint::NoFix` exception to skip over the problem.

For a more complete example of writing a `fix` method please read the
[tutorial](/developer/tutorial/).

## What you can use

There are a number of methods you can use to access the manifest and file
information in your `check` and `fix` methods.

### tokens

Returns the tokenised manifest as an Array of
[`PuppetLint::Lexer::Token`](/developer/tokens/) objects.

### title_tokens

Returns an Array of [`PuppetLint::Lexer::Token`](/developer/tokens/) objects
that represent resource titles.

### resource_indexes

Returns an Array of Hashes with the positions of all the resource declarations
within the tokenised manifest.  Each Hash has the following Symbol keys:

 * **:start -** The Integer position in the `tokens` Array (see above) pointing
   to the first token of the resource.
 * **:end -** The Integer position in the `tokens` Array (see above) pointing
   to the last token of the resource
 * **:tokens -** A subset of the `tokens` Array, from the `:start` to `:end`
   positions.
 * **:type -** The [`PuppetLint::Lexer::Token`](/developer/tokens/) object for
   resource type (e.g. `file`, `exec`, etc).
 * **:param_tokens -** An Array of
   [`PuppetLint::Lexer::Token`](/developer/tokens/) objects for the parameter
   names in the resource declaration.

### class_indexes

Returns an Array of Hashes with the positions of all the class definitions
within the tokenised manifest.  Each Hash has the following Symbol keys:

 * **:start -** The Integer position in the `tokens` Array (see above) pointing
   to the first token of the class.
 * **:end -** The Integer position in the `tokens` Array (see above) pointing
   to the last token of the class.
 * **:tokens -** A subset of the `tokens` Array, from the `:start` to `:end`
   positions.
 * **:param_tokens -** A subset of the `tokens` Array covering the class
   parameters.
 * **:type -** The Symbol `:CLASS`
 * **:name_token -**-The [`PuppetLint::Lexer::Token`](/developer/tokens/)
   object for the class name.
 * **:inherited_token -** The [`PuppetLint::Lexer::Token`](/developer/tokens/)
   object for the name of the class that has been inherited (if applicable).

### defined_type_indexes

Returns an Array of Hashes with the positions of all the defined type
definitions within the tokenised manifest.  Each Hash has the following Symbol
keys:

 * **:start -** The Integer position in the `tokens` Array (see above) pointing
   to the first token of the defined type.
 * **:end -** The Integer position in the `tokens` Array (see above) pointing
   to the last token of the defined type.
 * **:tokens -** A subset of the `tokens` Array, from the `:start` to `:end`
   positions.
 * **:param_tokens -** A subset of the `tokens` Array covering the defined type
   parameters.
 * **:type -** The Symbol `:DEFINE`
 * **:name_token -**-The [`PuppetLint::Lexer::Token`](/developer/tokens/)
   object for the defined type name.

### fullpath

Returns the expanded path to the manifest file that is being analysed.

### path

Returns the path to the manifest file as passed to puppet-lint.

### filename

Returns the name of the manifest file that is being analysed.

### manifest_lines

Returns the contents of the manifest file being analysed as an Array of lines.

### notify

Reports a problem in the manifest. Takes two arguments: A Symbol type of
problem (`:warning` or `:error`) and a Hash of information about the problem.
The Hash **must** contain the following keys, but can contain any other values
that you would like to pass to your `fix` method.

 * **:message -** A String describing the problem that will be displayed in the
   puppet-lint output.
 * **:line -** The Integer line number in the manifest file on which the
   problem can be found.
 * **:column -** The Integer column number on the line in the manifest file
   where the problem starts.
