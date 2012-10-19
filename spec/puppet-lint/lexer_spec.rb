require 'spec_helper'

describe PuppetLint::Lexer do
  before do
    @lexer = PuppetLint::Lexer.new
  end

  context 'invalid code' do
    it 'should bork' do
      expect { @lexer.tokenise('%') }.to raise_error(PuppetLint::LexerError)
    end
  end

  context '#new_token' do
    it 'should calculate the line number for an empty string' do
      token = @lexer.new_token(:TEST, 'test', :chunk => '')
      token.line.should == 1
    end

    it 'should calculate the line number for a multi line string' do
      token = @lexer.new_token(:TEST, 'test', :chunk => "foo\nbar")
      token.line.should == 2
    end

    it 'should calculate the column number for an empty string' do
      token = @lexer.new_token(:TEST, 'test', :chunk => '')
      token.column.should == 1
    end

    it 'should calculate the column number for a single line string' do
      token = @lexer.new_token(:TEST, 'test', :chunk => 'this is a test')
      token.column.should == 14
    end

    it 'should calculate the column number for a multi line string' do
      token = @lexer.new_token(:TEST, 'test', :chunk => "foo\nbar\nbaz\ngronk")
      token.column.should == 5
    end
  end

  context '#get_string_segment' do
    it 'should get a segment with a single terminator' do
      data = StringScanner.new('foo"bar')
      value, terminator = @lexer.get_string_segment(data, '"')
      value.should == 'foo'
      terminator.should == '"'
    end

    it 'should get a segment with multiple terminators' do
      data = StringScanner.new('foo"bar$baz')
      value, terminator = @lexer.get_string_segment(data, "'$")
      value.should == 'foo"bar'
      terminator.should == '$'
    end

    it 'should not get a segment with an escaped terminator' do
      data = StringScanner.new('foo"bar')
      value, terminator = @lexer.get_string_segment(data, '$')
      value.should be_nil
      terminator.should be_nil
    end
  end

  context '#interpolate_string' do
    it 'should handle a string with no variables' do
      @lexer.interpolate_string('foo bar baz"',1, 1)
      token = @lexer.tokens.first

      @lexer.tokens.length.should == 1
      token.type.should == :STRING
      token.value.should == 'foo bar baz'
      token.line.should == 1
      token.column.should == 1
    end

    it 'should handle a string with a newline' do
      @lexer.interpolate_string(%{foo\nbar"}, 1, 1)
      token = @lexer.tokens.first

      @lexer.tokens.length.should == 1
      token.type.should == :STRING
      token.value.should == "foo\nbar"
      token.line.should == 1
      token.column.should == 1
    end

    it 'should handle a string with a single variable and suffix' do
      @lexer.interpolate_string('${foo}bar"', 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == ''
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :VARIABLE
      tokens[1].value.should == 'foo'
      tokens[1].line.should == 1
      tokens[1].column.should == 3

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == 'bar'
      tokens[2].line.should == 1
      tokens[2].column.should == 8
    end

    it 'should handle a string with a single variable and surrounding text' do
      @lexer.interpolate_string('foo${bar}baz"', 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == 'foo'
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :VARIABLE
      tokens[1].value.should == 'bar'
      tokens[1].line.should == 1
      tokens[1].column.should == 6

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == 'baz'
      tokens[2].line.should == 1
      tokens[2].column.should == 11
    end

    it 'should handle a string with multiple variables and surrounding text' do
      @lexer.interpolate_string('foo${bar}baz${gronk}meh"', 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 5

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == 'foo'
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :VARIABLE
      tokens[1].value.should == 'bar'
      tokens[1].line.should == 1
      tokens[1].column.should == 6

      tokens[2].type.should == :DQMID
      tokens[2].value.should == 'baz'
      tokens[2].line.should == 1
      tokens[2].column.should == 11

      tokens[3].type.should == :VARIABLE
      tokens[3].value.should == 'gronk'
      tokens[3].line.should == 1
      tokens[3].column.should == 15

      tokens[4].type.should == :DQPOST
      tokens[4].value.should == 'meh'
      tokens[4].line.should == 1
      tokens[4].column.should == 22
    end

    it 'should handle a string with only a single variable' do
      @lexer.interpolate_string('${bar}"', 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == ''
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :VARIABLE
      tokens[1].value.should == 'bar'
      tokens[1].line.should == 1
      tokens[1].column.should == 3

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == ''
      tokens[2].line.should == 1
      tokens[2].column.should == 8
    end

    it 'should handle a string with only many variables' do
      @lexer.interpolate_string('${bar}${gronk}"', 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 5

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == ''
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :VARIABLE
      tokens[1].value.should == 'bar'
      tokens[1].line.should == 1
      tokens[1].column.should == 3

      tokens[2].type.should == :DQMID
      tokens[2].value.should == ''
      tokens[2].line.should == 1
      tokens[2].column.should == 8

      tokens[3].type.should == :VARIABLE
      tokens[3].value.should == 'gronk'
      tokens[3].line.should == 1
      tokens[3].column.should == 9

      tokens[4].type.should == :DQPOST
      tokens[4].value.should == ''
      tokens[4].line.should == 1
      tokens[4].column.should == 16
    end

    it 'should handle a string with only an unenclosed variable' do
      @lexer.interpolate_string('$foo"', 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == ''
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :UNENC_VARIABLE
      tokens[1].value.should == 'foo'
      tokens[1].line.should == 1
      tokens[1].column.should == 2

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == ''
      tokens[2].line.should == 1
      tokens[2].column.should == 6
    end

    it 'should handle a string with a nested string inside it' do
      @lexer.interpolate_string(%q{string with ${'a nested single quoted string'} inside it"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == 'string with '
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :SSTRING
      tokens[1].value.should == 'a nested single quoted string'
      tokens[1].line.should == 1
      tokens[1].column.should == 16

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == ' inside it'
      tokens[2].line.should == 1
      tokens[2].column.should == 48
    end

    it 'should handle a string with nested math' do
      @lexer.interpolate_string(%q{string with ${(3+5)/4} nested math"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 9

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == 'string with '
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :LPAREN
      tokens[1].line.should == 1
      tokens[1].column.should == 16

      tokens[2].type.should == :NUMBER
      tokens[2].value.should == '3'
      tokens[2].line.should == 1
      tokens[2].column.should == 17

      tokens[3].type.should == :PLUS
      tokens[3].line.should == 1
      tokens[3].column.should == 18

      tokens[4].type.should == :NUMBER
      tokens[4].value.should == '5'
      tokens[4].line.should == 1
      tokens[4].column.should == 19

      tokens[5].type.should == :RPAREN
      tokens[5].line.should == 1
      tokens[5].column.should == 20

      tokens[6].type.should == :DIV
      tokens[6].line.should == 1
      tokens[6].column.should == 21

      tokens[7].type.should == :NUMBER
      tokens[7].value.should == '4'
      tokens[7].line.should == 1
      tokens[7].column.should == 22

      tokens[8].type.should == :DQPOST
      tokens[8].value.should == ' nested math'
      tokens[8].line.should == 1
      tokens[8].column.should == 24
    end

    it 'should handle a string with a nested array' do
      @lexer.interpolate_string(%q{string with ${['an array ', $v2]} in it"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 8

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == 'string with '
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :LBRACK
      tokens[1].line.should == 1
      tokens[1].column.should == 16

      tokens[2].type.should == :SSTRING
      tokens[2].value.should == 'an array '
      tokens[2].line.should == 1
      tokens[2].column.should == 17

      tokens[3].type.should == :COMMA
      tokens[3].line.should == 1
      tokens[3].column.should == 28

      tokens[4].type.should == :WHITESPACE
      tokens[4].value.should == ' '
      tokens[4].line.should == 1
      tokens[4].column.should == 29

      tokens[5].type.should == :VARIABLE
      tokens[5].value.should == 'v2'
      tokens[5].line.should == 1
      tokens[5].column.should == 30

      tokens[6].type.should == :RBRACK
      tokens[6].line.should == 1
      tokens[6].column.should == 33

      tokens[7].type.should == :DQPOST
      tokens[7].value.should == ' in it'
      tokens[7].line.should == 1
      tokens[7].column.should == 35
    end

    it 'should handle a string of $s' do
      @lexer.interpolate_string(%q{$$$$"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 1

      tokens[0].type.should == :STRING
      tokens[0].value.should == '$$$$'
      tokens[0].line.should == 1
      tokens[0].column.should == 1
    end

    it 'should handle "$foo$bar"' do
      @lexer.interpolate_string(%q{$foo$bar"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 5

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == ''
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :UNENC_VARIABLE
      tokens[1].value.should == 'foo'
      tokens[1].line.should == 1
      tokens[1].column.should == 2

      tokens[2].type.should == :DQMID
      tokens[2].value.should == ''
      tokens[2].line.should == 1
      tokens[2].column.should == 6

      tokens[3].type.should == :UNENC_VARIABLE
      tokens[3].value.should == 'bar'
      tokens[3].line.should == 1
      tokens[3].column.should == 6

      tokens[4].type.should == :DQPOST
      tokens[4].value.should == ''
      tokens[4].line.should == 1
      tokens[4].column.should == 10
    end

    it 'should handle "foo$bar$"' do
      @lexer.interpolate_string(%q{foo$bar$"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == 'foo'
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :UNENC_VARIABLE
      tokens[1].value.should == 'bar'
      tokens[1].line.should == 1
      tokens[1].column.should == 5

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == '$'
      tokens[2].line.should == 1
      tokens[2].column.should == 9
    end

    it 'should handle "foo$$bar"' do
      @lexer.interpolate_string(%q{foo$$bar"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == 'foo$'
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :UNENC_VARIABLE
      tokens[1].value.should == 'bar'
      tokens[1].line.should == 1
      tokens[1].column.should == 6

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == ''
      tokens[2].line.should == 1
      tokens[2].column.should == 10
    end

    it 'should handle an empty string' do
      @lexer.interpolate_string(%q{"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 1

      tokens[0].type.should == :STRING
      tokens[0].value.should == ''
      tokens[0].line.should == 1
      tokens[0].column.should == 1
    end

    it 'should handle "$foo::::bar"' do
      @lexer.interpolate_string(%q{$foo::::bar"}, 1, 1)
      tokens = @lexer.tokens

      tokens.length.should == 3

      tokens[0].type.should == :DQPRE
      tokens[0].value.should == ''
      tokens[0].line.should == 1
      tokens[0].column.should == 1

      tokens[1].type.should == :UNENC_VARIABLE
      tokens[1].value.should == 'foo'
      tokens[1].line.should == 1
      tokens[1].column.should == 2

      tokens[2].type.should == :DQPOST
      tokens[2].value.should == '::::bar'
      tokens[2].line.should == 1
      tokens[2].column.should == 6
    end
  end

  [
    'case',
    'class',
    'default',
    'define',
    'import',
    'if',
    'elsif',
    'else',
    'inherits',
    'node',
    'and',
    'or',
    'undef',
    'true',
    'false',
    'in',
    'unless',
  ].each do |keyword|
    it "should handle '#{keyword}' as a keyword" do
      token = @lexer.tokenise(keyword).first
      token.type.should == keyword.upcase.to_sym
      token.value.should == keyword
    end
  end

  [
    [:LBRACK, '['],
    [:RBRACK, ']'],
    [:LBRACE, '{'],
    [:RBRACE, '}'],
    [:LPAREN, '('],
    [:RPAREN, ')'],
    [:EQUALS, '='],
    [:ISEQUAL, '=='],
    [:GREATEREQUAL, '>='],
    [:GREATERTHAN, '>'],
    [:LESSTHAN, '<'],
    [:LESSEQUAL, '<='],
    [:NOTEQUAL, '!='],
    [:NOT, '!'],
    [:COMMA, ','],
    [:DOT, '.'],
    [:COLON, ':'],
    [:AT, '@'],
    [:LLCOLLECT, '<<|'],
    [:RRCOLLECT, '|>>'],
    [:LCOLLECT, '<|'],
    [:RCOLLECT, '|>'],
    [:SEMIC, ';'],
    [:QMARK, '?'],
    [:BACKSLASH, '\\'],
    [:FARROW, '=>'],
    [:PARROW, '+>'],
    [:APPENDS, '+='],
    [:PLUS, '+'],
    [:MINUS, '-'],
    [:DIV, '/'],
    [:TIMES, '*'],
    [:LSHIFT, '<<'],
    [:RSHIFT, '>>'],
    [:MATCH, '=~'],
    [:NOMATCH, '!~'],
    [:IN_EDGE, '->'],
    [:OUT_EDGE, '<-'],
    [:IN_EDGE_SUB, '~>'],
    [:OUT_EDGE_SUB, '<~'],
  ].each do |name, string|
    it "should have a token named '#{name.to_s}'" do
      token = @lexer.tokenise(string).first
      token.type.should == name
      token.value.should == string
    end
  end

  context ':CLASSREF' do
    it 'should match single capitalised alphanumeric term' do
      token = @lexer.tokenise('One').first
      token.type.should == :CLASSREF
      token.value.should == 'One'
    end

    it 'should match two capitalised alphanumeric terms sep by ::' do
      token = @lexer.tokenise('One::Two').first
      token.type.should == :CLASSREF
      token.value.should == 'One::Two'
    end

    it 'should match many capitalised alphanumeric terms sep by ::' do
      token = @lexer.tokenise('One::Two::Three::Four::Five').first
      token.type.should == :CLASSREF
      token.value.should == 'One::Two::Three::Four::Five'
    end

    it 'should match capitalised terms prefixed by ::' do
      token = @lexer.tokenise('::One').first
      token.type.should == :CLASSREF
      token.value.should == '::One'
    end
  end

  context ':NAME' do
    it 'should match lowercase alphanumeric terms' do
      token = @lexer.tokenise('one-two').first
      token.type.should == :NAME
      token.value.should == 'one-two'
    end

    it 'should match lowercase alphanumeric terms sep by ::' do
      token = @lexer.tokenise('one::two').first
      token.type.should == :NAME
      token.value.should == 'one::two'
    end

    it 'should match many lowercase alphanumeric terms sep by ::' do
      token = @lexer.tokenise('one::two::three::four::five').first
      token.type.should == :NAME
      token.value.should == 'one::two::three::four::five'
    end

    it 'should match lowercase alphanumeric terms prefixed by ::' do
      token = @lexer.tokenise('::1one::2two::3three').first
      token.type.should == :NAME
      token.value.should == '::1one::2two::3three'
    end
  end

  context ':NUMBER' do
    it 'should match numeric terms' do
      token = @lexer.tokenise('1234567890').first
      token.type.should == :NUMBER
      token.value.should == '1234567890'
    end

    it 'should match float terms' do
      token = @lexer.tokenise('12345.6789').first
      token.type.should == :NUMBER
      token.value.should == '12345.6789'
    end

    it 'should match hexadecimal terms' do
      token = @lexer.tokenise('0xCAFE1029').first
      token.type.should == :NUMBER
      token.value.should == '0xCAFE1029'
    end

    it 'should match float with exponent terms' do
      token = @lexer.tokenise('10e23').first
      token.type.should == :NUMBER
      token.value.should == '10e23'
    end

    it 'should match float with negative exponent terms' do
      token = @lexer.tokenise('10e-23').first
      token.type.should == :NUMBER
      token.value.should == '10e-23'
    end

    it 'should match float with exponent terms' do
      token = @lexer.tokenise('1.234e5').first
      token.type.should == :NUMBER
      token.value.should == '1.234e5'
    end
  end

  context ':COMMENT' do
    it 'should match everything on a line after #' do
      token = @lexer.tokenise('foo # bar baz')[2]
      token.type.should == :COMMENT
      token.value.should == 'bar baz'
    end
  end

  context ':MLCOMMENT' do
    it 'should match comments on a single line' do
      token = @lexer.tokenise('/* foo bar */').first
      token.type.should == :MLCOMMENT
      token.value.should == 'foo bar'
    end

    it 'should match comments on multiple lines' do
      token = @lexer.tokenise("/*\n * foo bar\n*/").first
      token.type.should == :MLCOMMENT
      token.value.should == 'foo bar'
    end
  end

  context ':SLASH_COMMENT' do
    it 'should match everyone on a line after //' do
      token = @lexer.tokenise('foo // bar baz')[2]
      token.type.should == :SLASH_COMMENT
      token.value.should == 'bar baz'
    end
  end

  context ':SSTRING' do
    it 'should match a single quoted string' do
      token = @lexer.tokenise("'single quoted string'").first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string'
    end

    it "should match a single quoted string with an escaped '" do
      token = @lexer.tokenise(%q{'single quoted string with "\\'"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\\'"'
    end

    it "should match a single quoted string with an escaped $" do
      token = @lexer.tokenise(%q{'single quoted string with "\$"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\$"'
    end

    it "should match a single quoted string with an escaped ." do
      token = @lexer.tokenise(%q{'single quoted string with "\."'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\."'
    end

    it "should match a single quoted string with an escaped \\n" do
      token = @lexer.tokenise(%q{'single quoted string with "\n"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\n"'
    end

    it "should match a single quoted string with an escaped \\" do
      token = @lexer.tokenise(%q{'single quoted string with "\\\\"'}).first
      token.type.should == :SSTRING
      token.value.should == 'single quoted string with "\\\\"'
    end

    it "should match an empty string" do
      token = @lexer.tokenise("''").first
      token.type.should == :SSTRING
      token.value.should == ''
    end

    it "should match an empty string ending with \\\\" do
      token = @lexer.tokenise("'foo\\\\'").first
      token.type.should == :SSTRING
      token.value.should == %{foo\\\\}
    end
  end

  context ':REGEX' do
    it 'should match anything enclosed in //' do
      token = @lexer.tokenise('/this is a regex/').first
      token.type.should == :REGEX
      token.value.should == 'this is a regex'
    end

    it 'should not match if there is \n in the regex' do
      token = @lexer.tokenise("/this is \n a regex/").first
      token.type.should_not == :REGEX
    end

    it 'should not consider \/ to be the end of the regex' do
      token = @lexer.tokenise('/this is \/ a regex/').first
      token.type.should == :REGEX
      token.value.should == 'this is \\/ a regex'
    end

    it 'should not match chained division' do
      tokens = @lexer.tokenise('$x = $a/$b/$c')
      tokens.select { |r| r.type == :REGEX }.should == []
    end
  end

  context ':STRING' do
    it 'should parse strings with \\\\\\' do
      expect {
        @lexer.tokenise("exec { \"/bin/echo \\\\\\\"${environment}\\\\\\\"\": }")
      }.to_not raise_error(PuppetLint::LexerError)
    end
  end
end
