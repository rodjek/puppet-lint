---
layout: nomenu
---
{:.page-title}
# PuppetLint::Lexer::Token

##### #new

Creates a new `PuppetLint::Lexer::Token` object. Takes 4 arguments:

{:.list-featured .space-bottom-20}
  * The token type (see the tables below)
  * The value of the token (used when rendering the fixed manifest)
  * The line number that the token was found on
  * The column number that the token started in

##### #line

Returns the line number that the token was found on.

##### #column

Returns the column number that the token started on.

##### #type

Returns the type of the token.

##### #value

Returns the value of the token.

##### #to\_manifest

Returns a rendered version of the token as it would appear in the manifest.

##### #next\_token

Returns the next `PuppetLint::Lexer::Token` object in the manifest.

##### #next\_code\_token

Returns the next `PuppetLint::Lexer::Token` object in the manifest that is not
a formatting token (whitespace and comment tokens, see the tables below).

##### #next\_token\_of

Search for the next `PuppetLint::Lexer::Token` object of a given type. Takes
2 arguments:

{:.list-featured .space-bottom-20}
  * The token type (see the tables below) or an array of types.
  * A hash of options to limit the result of the search:
    * `:value` - A token value to search for in addition to type.
    * `:skip_blocks` - If `true`, the search will skip over blocks of tokens
      (delimited by `( )`, `{ }`, or `[ ]`).

##### #prev\_token

Returns the previous `PuppetLint::Lexer::Token` object in the manifest.

##### #prev\_code\_token

Returns the previous `PuppetLint::Lexer::Token` object in the manifest that is
not a formatting token (whitespace and comment tokens, see the tables below).

##### #prev\_token\_of

Search for the previous `PuppetLint::Lexer::Token` object of a given type. Takes
2 arguments:

{:.list-featured .space-bottom-20}
  * The token type (see the tables below) or an array of types.
  * A hash of options to limit the result of the search:
    * `:value` - A token value to search for in addition to type.
    * `:skip_blocks` - If `true`, the search will skip over blocks of tokens
      (delimited by `( )`, `{ }`, or `[ ]`).

{:.page-title}
# Token Types

{:.section-title}
## Keywords

{:.table}
|-------------|------------|
| Token Type  | Value      |
|-------------|------------|
| `:AND`      | `and`      |
| `:ATTR`     | `attr`     |
| `:CASE`     | `case`     |
| `:CLASS`    | `class`    |
| `:DEFAULT`  | `default`  |
| `:DEFINE`   | `define`   |
| `:ELSE`     | `else`     |
| `:ELSIF`    | `elsif`    |
| `:FALSE`    | `false`    |
| `:FUNCTION` | `function` |
| `:IF`       | `if`       |
| `:IMPORT`   | `import`   |
| `:IN`       | `in`       |
| `:INHERITS` | `inherits` |
| `:NODE`     | `node`     |
| `:OR`       | `or`       |
| `:PRIVATE`  | `private`  |
| `:TRUE`     | `true`     |
| `:TYPE`     | `type`     |
| `:UNDEF`    | `undef`    |
| `:UNLESS`   | `unless`   |
|-------------|------------|

{:.section-title}
## Symbols

{:.table}
|-----------------|-------|
| Token Type      | Value |
|-----------------|-------|
| `:LBRACK`       | `[`   |
| `:RBRACK`       | `]`   |
| `:LBRACE`       | `{`   |
| `:RBRACE`       | `}`   |
| `:LPAREN`       | `(`   |
| `:RPAREN`       | `)`   |
| `:ISEQUAL`      | `==`  |
| `:MATCH`        | `=~`  |
| `:FARROW`       | `=>`  |
| `:EQUALS`       | `=`   |
| `:APPENDS`      | `+=`  |
| `:PARROW`       | `+>`  |
| `:PLUS`         | `+`   |
| `:GREATEREQUAL` | `>=`  |
| `:RSHIFT`       | `>>`  |
| `:GREATERTHAN`  | `>`   |
| `:LESSEQUAL`    | `<=`  |
| `:LLCOLLECT`    | `<<|` |
| `:OUT_EDGE`     | `<-`  |
| `:OUT_EDGE_SUB` | `<~`  |
| `:LCOLLECT`     | `<|`  |
| `:LSHIFT`       | `<<`  |
| `:LESSTHAN`     | `<`   |
| `:NOMATCH`      | `!~`  |
| `:NOTEQUAL`     | `!=`  |
| `:NOT`          | `!`   |
| `:RRCOLLECT`    | `|>>` |
| `:RCOLLECT`     | `|>`  |
| `:IN_EDGE`      | `->`  |
| `:IN_EDGE_SUB`  | `~>`  |
| `:MINUS`        | `-`   |
| `:COMMA`        | `,`   |
| `:DOT`          | `.`   |
| `:COLON`        | `:`   |
| `:SEMIC`        | `;`   |
| `:QMARK`        | `?`   |
| `:BACKSLASH`    | `\`   |
| `:TIMES`        | `*`   |
| `:MODULO`       | `%`   |
| `:PIPE`         | `|`   |
| `:DIV`          | `/`   |
| `:AT`           | `@`   |
|-----------------|-------|

{:.section-title}
## Whitespace

{:.table}
|---------------|----------------------------------------------------------------------------------------------------------|
| Token Type    | Value                                                                                                    |
|---------------|----------------------------------------------------------------------------------------------------------|
| `:NEWLINE`    | A carriage return (`\r`), a line feed (`\n`), or a combination of both                                   |
| `:WHITESPACE` | A block of 1 or more space or tab (`\t`) characters                                                      |
| `:INDENT`     | A special token for `:WHITESPACE` that occurs at the start of a line (directly after a `:NEWLINE` token) |
|---------------|----------------------------------------------------------------------------------------------------------|

{:.section-title}
## Comments

{:.table}
|------------------|--------------------------------------------|
| Token Type       | Value                                      |
|------------------|--------------------------------------------|
| `:COMMENT`       | A single line comment starting with a `#`  |
| `:MLCOMMENT`     | A multi line comment between `/*` and `*/` |
| `:SLASH_COMMENT` | A single line comment starting with `//`   |
|------------------|--------------------------------------------|

{:.section-title}
## Strings

{:.table}
|------------|-----------------------------------------------------------------------------|
| Token Type | Value                                                                       |
|------------|-----------------------------------------------------------------------------|
| `:SSTRING` | A string contained within single quotes (`'`)                               |
| `:REGEX`   | A string contained withing slashes (`/`)                                    |
| `:STRING`  | A string contained within double quotes (`"`) that contains no other tokens |
|------------|-----------------------------------------------------------------------------|

When double quoted strings contain other tokens due to interpolated values, the
string is split up into multiple tokens.

{:.table}
|------------|-------|
| Token Type | Value |
|------------|-------|
| `:DQPRE`   | The part of the string from the beginning until the first contained token (e.g. if tokenising `"foo ${bar} baz ${gronk} qux"`, the `:DQPRE` token would have the value `foo ` |
| `:DQMID`   | The part of the string that is between two contained tokens (e.g. if tokenising `"foo ${bar} baz ${gronk} qux"`, the `:DQMID` token would have the value ` baz ` |
| `:DQPOST`  | The part of the string from the last token to the end of the string (e.g. if tokenising `"foo ${bar} baz ${gronk} qux"`, the `:DQPOST` token would have the value ` qux` |
|------------|-------|

{:.section-title}
## Heredocs

{:.table}
|-----------------|-------------------------------------------------------------------------------------|
| Token Type      | Value                                                                               |
|-----------------|-------------------------------------------------------------------------------------|
| `:HEREDOC_OPEN` | The opening token that describes the heredoc that will follow (e.g. `@(myheredoc)`) |
| `:HEREDOC`      | The contents of a heredoc that contains no interpolated values                      |
|-----------------|-------------------------------------------------------------------------------------|

Similarly to how double quoted strings are handled, heredocs that contain
interpolated values are split into `:HEREDOC_PRE`, `:HEREDOC_MID`, and
`:HEREDOC_POST` tokens (see the `:DQPRE`, `:DQMID`, and `:DQPOST` descriptions
above).

{:.section-title}
## Other

{:.table}
|-------------------|-------------------------------------------------------------------------------------------------|
| Token Type        | Value                                                                                           |
|-------------------|-------------------------------------------------------------------------------------------------|
| `:NUMBER`         | A number expressed in decimal (`123`), hexidecimal (`0x123`) or in scientific notation (`12e3`) |
| `:NAME`           | A lowercase bare word or sequence of bare words joined by double colons (`::`)                  |
| `:CLASSREF`       | A special case of the `:NAME` token, where the bare words have been capitalised                 |
| `:VARIABLE`       | A special case ofthe `:NAME` token, where the value is prefixed with a `$`                      |
| `:UNENC_VARIABLE` | A special case of the `:VARIABLE` token that can only exist in a double quoted string or heredoc where the variable has not been enclosed in braces (e.g. `$foo` instead of `${foo}`) |
|-------------------|-------------------------------------------------------------------------------------------------|

