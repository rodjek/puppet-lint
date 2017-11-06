---
layout: nomenu
---
{:.page-title}
# Check Plugin API

{:.section-title}
## What you need to implement

To defined a new check, you need to create a new `PuppetLint::CheckPlugin`
subclass with a `check` method, an optional `fix` method, and register the
check with puppet-lint. The easiest way to do this is with the following:

{% highlight ruby %}
PuppetLint.new_check(:check_name) do
  def check
    # ...
  end
end
{% endhighlight %}

##### check

In your check plugin class (see above), you must define a `check` method that
uses the `notify` method (see below) to report problems in the manifest. You
can use any of the methods listed in the "What you can use" section below to
inspect the manifest.

For a more complete example of writing a `check` method, please read the
[tutorial](/documentation/developer/plugin_tutorial/).

##### fix

In you check plugin class (see above), you can optionally define a `fix` method
that will be called on every problem submitted with `notify` in your `check`
method. Your `fix` method **must** take one parameter and will be passed the
hash of information submitted with `notify`.

In your `fix` method, you should make your changes to the manifest by modifying
the `tokens` array. If you need to back out of the `fix` method for whatever
reason, raise a `PuppetLint::NoFix` exception to skip over the problem.

For a more complete example of writing a `fix` method, please read the
[tutorial](/documentation/developer/plugin_tutorial/).

{:.section-title}
## What you can use

##### tokens

Returns the tokenised manifest as an array of `PuppetLint::Lexer::Token`
objects.

##### title\_tokens

Returns an array of `PuppetLint::Lexer::Token` objects that represent resource
titles.

##### resource\_indexes

Returns an array of hashes with the positions of all of the resource
declarations within the tokenised manifest. Each hash has the following keys:

{:.list-featured .space-bottom-20}
  * **:start -** The position of the first token of the resource within the
    `tokens` array.
  * **:end -** The position of the last token of the resource within the
    `tokens` array.
  * **:tokens -** A subset of the `tokens` array, from the `:start` to `:end`
    positions.
  * **:type -** The `PuppetLint::Lexer::Token` object for the resource type
    (e.g. `file`, `exec`, etc).
  * **:param\_tokens -** An array of `PuppetLint::Lexer::Token` objects for the
    parameter names in the resource declaration.

##### class\_indexes

Returns an array of hashes with the positions of all the class definitions
within the tokenised manifest. Each hash has the following keys:

{:.list-featured .space-bottom-20}
  * **:start -** The position of the first token of the class within the
    `tokens` array.
  * **:end -** The position of the last token of the class within the `tokens`
    array.
  * **:tokens -** A subset of the `tokens` array, from the `:start` to `:end`
    positions.
  * **:param\_tokens -** A subset of the `tokens` array, covering the class
    parameters.
  * **:type -** The symbol `:CLASS`.
  * **:name\_token -** The `PuppetLint::Lexer::Token` object containing the
    class name.
  * **:inherited\_token -** The `PuppetLint::Lexer::Token` object containing
    the name of the class that this class inherits (if applicable).

##### defined\_type\_indexes

Returns an array of hashes with the positions of all the defined type
definitions within the tokenised manifest. Each hash has the following keys:

{:.list-featured .space-bottom-20}
  * **:start -** The position of the first token of the defined type within the
    `tokens` array.
  * **:end -** The position of the last token of the defined type within the
    `tokens` array.
  * **:tokens -** A subset of the `tokens` array, from the `:start` to `:end`
    positions.
  * **:param\_tokens -** A subset of the `tokens` array, covering the defined
    type parameters.
  * **:type -** The symbol `:DEFINE`.
  * **:name\_token -** The `PuppetLint::Lexer::Token` object containing the
    defined type name.

##### node\_indexes

Returns an array of hashes with the positions of all the node definitions
within the tokenised manifest. Each hash has the following keys:

{:.list-featured .space-bottom-20}
  * **:start -** The position of the first token of the node within the
    `tokens` array.
  * **:end -** The position of the last token of the node within the `tokens`
    array.
  * **:tokens -** A subset of the `tokens` array, from the `:start` to `:end`
    positions.
  * **:type -** The symbol `:NODE`.
  * **:name\_token -** The `PuppetLint::Lexer::Token` object containing the
    node name.
  * **:inherited\_token -** The `PuppetLint::Lexer::Token` object containing
    the name of the node that this node inherits (if applicable).

##### fullpath

Returns the expanded path to the manifest file that is being analysed.

##### path

Returns the path to the manifest file that is being analysed, as it was passed
to puppet-lint.

##### filename

Returns the name of the manifest file that is being analysed.

##### manifest\_lines

Returns the contents of the manifest file that is being analysed as an array of
lines.

##### formatting\_tokens

Returns a list of token types (as symbols) that puppet-lint considers to be
formatting or non-code tokens (whitespace, comments, etc).

##### add\_token

Inserts a `PuppetLint::Lexer::Token` object into the `tokens` array at the
specified index and updates the links between tokens. Do not insert new tokens
into the `tokens` array manually.

This method takes two arguments:

{:.list-featured .space-bottom-20}
  * The `PuppetLint::Lexer::Token` object to be inserted.
  * The position in the `tokens` array where the token should be inserted.

##### remove\_token

Removes a `PuppetLint::Lexer::Token` object from the `tokens` array and updates
the links between tokens. Do not remove tokens from the `tokens` array
manually.

This method takes one argument:

{:.list-featured .space-bottom-20}
  * The `PuppetLint::Lexer::Token` object to be removed.
