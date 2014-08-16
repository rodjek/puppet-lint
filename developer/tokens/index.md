---
layout: default
---
# Token Types

## Keywords

`:CLASS`
: `class`

`:CASE`
: `case`

`:DEFAULT`
: `default`

`:DEFINE`
: `define`

`:IMPORT`
: `import`

`:IF`
: `if`

`:ELSE`
: `else`

`:ELSIF`
: `elsif`

`:INHERITS`
: `inherits`

`:NODE`
: `node`

`:AND`
: `and`

`:OR`
: `or`

`:UNDEF`
: `undef`

`:TRUE`
: `true`

`:FALSE`
: `false`

`:IN`
: `in`

`:UNLESS`
: `unless`

## Symbols
`:LBRACK`
: `[`

`:RBRACK`
: `]`

`:LBRACE`
: `{`

`:RBRACE`
: `}`

`:LPAREN`
: `(`

`:RPAREN`
: `)`

`:ISEQUAL`
: `==`

`:MATCH`
: `=~`

`:FARROW`
: `=>`

`:EQUALS`
: `=`

`:APPENDS`
: `+=`

`:PARROW`
: `+>`

`:PLUS`
: `+`

`:GREATEREQUAL`
: `>=`

`:RSHIFT`
: `>>`

`:GREATERTHAN`
: `>`

`:LESSEQUAL`
: `<=`

`:LLCOLLECT`
: `<<|`

`:OUT_EDGE`
: `<-`

`:OUT_EDGE_SUB`
: `<~`

`:LCOLLECT`
: `<|`

`:LSHIFT`
: `<<`

`:LESSTHAN`
: `<`

`:NOMATCH`
: `!~`

`:NOTEQUAL`
: `!=`

`:NOT`
: `!`

`:RRCOLLECT`
: `|>>`

`:RCOLLECT`
: `|>`

`:IN_EDGE`
: `->`

`:IN_EDGE_SUB`
: `~>`

`:MINUS`
: `-`

`:COMMA`
: `,`

`:DOT`
: `.`

`:COLON`
: `:`

`:AT`
: `@`

`:SEMIC`
: `;`

`:QMARK`
: `?`

`:BACKSLASH`
: `\`

`:TIMES`
: `*`

`:MODULO`
: `%`

`:PIPE`
: `|`

`:DIV`
: `/`

## Whitespace
`:NEWLINE`
: A carriage return (`\r`), a line feed (`\n`) or, a combination of both.

`:WHITESPACE`
: A block of 1 or more space or tab (`\t`) characters.

`:INDENT`
: A special token for `:WHITESPACE` that occurs at the start of a line
(directly after a `:NEWLINE` token).

## Comments
`:COMMENT`
: A single line comment starting with a hash (e.g. `# foo`).

`:MLCOMMENT`
: A multiline comment between `/*` and `*/`.

`:SLASH_COMMENT`
: A single line comment starting with two slashes (e.g. `// foo`).

## Strings
`:SSTRING`
: A string contained within single quotes (e.g. `'foo'`).

`:REGEX`
: A string contained within slashes (e.g. `/foo/`).

`:STRING`
: A double quoted string that contains no other tokens such as variables (e.g.
`"foo"`).

When double quoted strings contain other tokens such as variables, the string
is split up into multiple tokens.

`:DQPRE`
: The part of the string from the beginning until the first token (e.g. If
tokenising `"foo ${bar} baz ${gronk} qux"`, the `:DQPRE` token would have the
value "foo ").

`:DQMID`
: The part of the string that comes between tokens (e.g. If tokenising `"foo
${bar} baz ${gronk} qux"`, there would be a single `:DQMID` token with the value
" baz ").

`:DQPOST`
: The part of the string from the last token until the end of the string (e.g.
If tokenising `"foo ${bar} baz ${gronk} qux"`, the `:DQPOST` token would have
the value " qux").

## Other
`:NUMBER`
: A number expressed in decimal (`123`), in hexidecimal (`0x123`) or in
scientific notation ('12e3').

`:NAME`
: A lowercase bare word or sequence of bare words joined by double colons
(`::`) (e.g. `foo::bar`, `thing2`).

`:CLASSREF`
: A special case for the `:NAME` token where the word starts with capital
letter (e.g. `Foo`, `Foo::Bar`).

`:VARIABLE`
: A special case for the `:NAME` token where the value is prefixed with
a dollar sign (`$`) (e.g. `$foo`, `$::foo::bar`).

`:UNENC_VARIABLE`
: A special case for the `:VARIABLE` token which can only exist in a double
quoted string (i.e. between `:DQPRE` and `:DQPOST` tokens). Variables found
inside those strings will have a token type of :VARIABLE if they are enclosed
in braces (e.g. `${foo}`), if not, they will have the type `:UNENC_VARIABLE`.
