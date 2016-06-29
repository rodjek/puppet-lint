require 'spec_helper'

describe PuppetLint::Lexer do
  before do
    @lexer = PuppetLint::Lexer.new
  end

  context 'invalid code' do
    it 'should bork' do
      expect { @lexer.tokenise('^') }.to raise_error(PuppetLint::LexerError)
    end
  end

  context '#new_token' do
    it 'should calculate the line number for an empty string' do
      token = @lexer.new_token(:TEST, 'test', 4)
      expect(token.line).to eq(1)
    end

    it 'should calculate the line number for a multi line string' do
      @lexer.instance_variable_set('@line_no', 2)
      token = @lexer.new_token(:TEST, 'test', 4)
      expect(token.line).to eq(2)
    end

    it 'should calculate the column number for an empty string' do
      token = @lexer.new_token(:TEST, 'test', 4)
      expect(token.column).to eq(1)
    end

    it 'should calculate the column number for a single line string' do
      @lexer.instance_variable_set('@column', 'this is a test'.size)
      token = @lexer.new_token(:TEST, 'test', 4)
      expect(token.column).to eq(14)
    end

    it 'should calculate the column number for a multi line string' do
      @lexer.instance_variable_set('@line_no', 4)
      @lexer.instance_variable_set('@column', "gronk".size)
      token = @lexer.new_token(:TEST, 'test', 4)
      expect(token.column).to eq(5)
    end
  end

  context '#get_string_segment' do
    it 'should get a segment with a single terminator' do
      data = StringScanner.new('foo"bar')
      value, terminator = @lexer.get_string_segment(data, '"')
      expect(value).to eq('foo')
      expect(terminator).to eq('"')
    end

    it 'should get a segment with multiple terminators' do
      data = StringScanner.new('foo"bar$baz')
      value, terminator = @lexer.get_string_segment(data, "'$")
      expect(value).to eq('foo"bar')
      expect(terminator).to eq('$')
    end

    it 'should not get a segment with an escaped terminator' do
      data = StringScanner.new('foo"bar')
      value, terminator = @lexer.get_string_segment(data, '$')
      expect(value).to be_nil
      expect(terminator).to be_nil
    end
  end

  context '#interpolate_string' do
    it 'should handle a string with no variables' do
      @lexer.interpolate_string('foo bar baz"',1, 1)
      token = @lexer.tokens.first

      expect(@lexer.tokens.length).to eq(1)
      expect(token.type).to eq(:STRING)
      expect(token.value).to eq('foo bar baz')
      expect(token.line).to eq(1)
      expect(token.column).to eq(1)
    end

    it 'should handle a string with a newline' do
      @lexer.interpolate_string(%{foo\nbar"}, 1, 1)
      token = @lexer.tokens.first

      expect(@lexer.tokens.length).to eq(1)
      expect(token.type).to eq(:STRING)
      expect(token.value).to eq("foo\nbar")
      expect(token.line).to eq(1)
      expect(token.column).to eq(1)
    end

    it 'should handle a string with a single variable and suffix' do
      @lexer.interpolate_string('${foo}bar"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('foo')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(3)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('bar')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(8)
    end

    it 'should handle a string with a single variable and surrounding text' do
      @lexer.interpolate_string('foo${bar}baz"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('foo')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('bar')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(6)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('baz')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(11)
    end

    it 'should handle a string with multiple variables and surrounding text' do
      @lexer.interpolate_string('foo${bar}baz${gronk}meh"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(5)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('foo')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('bar')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(6)

      expect(tokens[2].type).to eq(:DQMID)
      expect(tokens[2].value).to eq('baz')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(11)

      expect(tokens[3].type).to eq(:VARIABLE)
      expect(tokens[3].value).to eq('gronk')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(15)

      expect(tokens[4].type).to eq(:DQPOST)
      expect(tokens[4].value).to eq('meh')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(22)
    end

    it 'should handle a string with only a single variable' do
      @lexer.interpolate_string('${bar}"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('bar')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(3)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(8)
    end

    it 'should handle a variable with an array reference' do
      @lexer.interpolate_string('${foo[bar][baz]}"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('foo[bar][baz]')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(3)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(18)
    end

    it 'should handle a string with only many variables' do
      @lexer.interpolate_string('${bar}${gronk}"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(5)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('bar')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(3)

      expect(tokens[2].type).to eq(:DQMID)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(8)

      expect(tokens[3].type).to eq(:VARIABLE)
      expect(tokens[3].value).to eq('gronk')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(9)

      expect(tokens[4].type).to eq(:DQPOST)
      expect(tokens[4].value).to eq('')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(16)
    end

    it 'should handle a string with only an unenclosed variable' do
      @lexer.interpolate_string('$foo"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:UNENC_VARIABLE)
      expect(tokens[1].value).to eq('foo')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(2)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
    end

    it 'should handle a string with a nested string inside it' do
      @lexer.interpolate_string(%q{string with ${'a nested single quoted string'} inside it"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('string with ')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:SSTRING)
      expect(tokens[1].value).to eq('a nested single quoted string')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(16)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq(' inside it')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(48)
    end

    it 'should handle a string with nested math' do
      @lexer.interpolate_string(%q{string with ${(3+5)/4} nested math"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(9)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('string with ')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:LPAREN)
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(16)

      expect(tokens[2].type).to eq(:NUMBER)
      expect(tokens[2].value).to eq('3')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(17)

      expect(tokens[3].type).to eq(:PLUS)
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(18)

      expect(tokens[4].type).to eq(:NUMBER)
      expect(tokens[4].value).to eq('5')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(19)

      expect(tokens[5].type).to eq(:RPAREN)
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(20)

      expect(tokens[6].type).to eq(:DIV)
      expect(tokens[6].line).to eq(1)
      expect(tokens[6].column).to eq(21)

      expect(tokens[7].type).to eq(:NUMBER)
      expect(tokens[7].value).to eq('4')
      expect(tokens[7].line).to eq(1)
      expect(tokens[7].column).to eq(22)

      expect(tokens[8].type).to eq(:DQPOST)
      expect(tokens[8].value).to eq(' nested math')
      expect(tokens[8].line).to eq(1)
      expect(tokens[8].column).to eq(24)
    end

    it 'should handle a string with a nested array' do
      @lexer.interpolate_string(%q{string with ${['an array ', $v2]} in it"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(8)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('string with ')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:LBRACK)
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(16)

      expect(tokens[2].type).to eq(:SSTRING)
      expect(tokens[2].value).to eq('an array ')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(17)

      expect(tokens[3].type).to eq(:COMMA)
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(28)

      expect(tokens[4].type).to eq(:WHITESPACE)
      expect(tokens[4].value).to eq(' ')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(29)

      expect(tokens[5].type).to eq(:VARIABLE)
      expect(tokens[5].value).to eq('v2')
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(30)

      expect(tokens[6].type).to eq(:RBRACK)
      expect(tokens[6].line).to eq(1)
      expect(tokens[6].column).to eq(33)

      expect(tokens[7].type).to eq(:DQPOST)
      expect(tokens[7].value).to eq(' in it')
      expect(tokens[7].line).to eq(1)
      expect(tokens[7].column).to eq(35)
    end

    it 'should handle a string of $s' do
      @lexer.interpolate_string(%q{$$$$"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(1)

      expect(tokens[0].type).to eq(:STRING)
      expect(tokens[0].value).to eq('$$$$')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
    end

    it 'should handle "$foo$bar"' do
      @lexer.interpolate_string(%q{$foo$bar"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(5)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:UNENC_VARIABLE)
      expect(tokens[1].value).to eq('foo')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(2)

      expect(tokens[2].type).to eq(:DQMID)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)

      expect(tokens[3].type).to eq(:UNENC_VARIABLE)
      expect(tokens[3].value).to eq('bar')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(6)

      expect(tokens[4].type).to eq(:DQPOST)
      expect(tokens[4].value).to eq('')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(10)
    end

    it 'should handle "foo$bar$"' do
      @lexer.interpolate_string(%q{foo$bar$"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('foo')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:UNENC_VARIABLE)
      expect(tokens[1].value).to eq('bar')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('$')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(9)
    end

    it 'should handle "foo$$bar"' do
      @lexer.interpolate_string(%q{foo$$bar"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('foo$')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:UNENC_VARIABLE)
      expect(tokens[1].value).to eq('bar')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(6)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(10)
    end

    it 'should handle an empty string' do
      @lexer.interpolate_string(%q{"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(1)

      expect(tokens[0].type).to eq(:STRING)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
    end

    it 'should handle "$foo::::bar"' do
      @lexer.interpolate_string(%q{$foo::::bar"}, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:UNENC_VARIABLE)
      expect(tokens[1].value).to eq('foo')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(2)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('::::bar')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
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
      expect(token.type).to eq(keyword.upcase.to_sym)
      expect(token.value).to eq(keyword)
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
    [:MODULO, '%'],
    [:PIPE, '|'],
    [:LSHIFT, '<<'],
    [:RSHIFT, '>>'],
    [:MATCH, '=~'],
    [:NOMATCH, '!~'],
    [:IN_EDGE, '->'],
    [:OUT_EDGE, '<-'],
    [:IN_EDGE_SUB, '~>'],
    [:OUT_EDGE_SUB, '<~'],
    [:NEWLINE, "\r"],
    [:NEWLINE, "\n"],
    [:NEWLINE, "\r\n"],
  ].each do |name, string|
    it "should have a token named '#{name.to_s}'" do
      token = @lexer.tokenise(string).first
      expect(token.type).to eq(name)
      expect(token.value).to eq(string)
    end
  end

  context ':TYPE' do
    it 'should match Data Types' do
      token = @lexer.tokenise('Integer').first
      expect(token.type).to eq(:TYPE)
      expect(token.value).to eq('Integer')
    end

    it 'should match Catalog Types' do
      token = @lexer.tokenise('Resource').first
      expect(token.type).to eq(:TYPE)
      expect(token.value).to eq('Resource')
    end

    it 'should match Abstract Types' do
      token = @lexer.tokenise('Collection').first
      expect(token.type).to eq(:TYPE)
      expect(token.value).to eq('Collection')
    end

    it 'should match Platform Types' do
      token = @lexer.tokenise('Callable').first
      expect(token.type).to eq(:TYPE)
      expect(token.value).to eq('Callable')
    end
  end

  context ':CLASSREF' do
    it 'should match single capitalised alphanumeric term' do
      token = @lexer.tokenise('One').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('One')
    end

    it 'should match two capitalised alphanumeric terms sep by ::' do
      token = @lexer.tokenise('One::Two').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('One::Two')
    end

    it 'should match many capitalised alphanumeric terms sep by ::' do
      token = @lexer.tokenise('One::Two::Three::Four::Five').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('One::Two::Three::Four::Five')
    end

    it 'should match capitalised terms prefixed by ::' do
      token = @lexer.tokenise('::One').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('::One')
    end
  end

  context ':NAME' do
    it 'should match lowercase alphanumeric terms' do
      token = @lexer.tokenise('one-two').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('one-two')
    end

    it 'should match lowercase alphanumeric terms sep by ::' do
      token = @lexer.tokenise('one::two').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('one::two')
    end

    it 'should match many lowercase alphanumeric terms sep by ::' do
      token = @lexer.tokenise('one::two::three::four::five').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('one::two::three::four::five')
    end

    it 'should match lowercase alphanumeric terms prefixed by ::' do
      token = @lexer.tokenise('::1one::2two::3three').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('::1one::2two::3three')
    end
  end

  context ':NUMBER' do
    it 'should match numeric terms' do
      token = @lexer.tokenise('1234567890').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('1234567890')
    end

    it 'should match float terms' do
      token = @lexer.tokenise('12345.6789').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('12345.6789')
    end

    it 'should match hexadecimal terms' do
      token = @lexer.tokenise('0xCAFE1029').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('0xCAFE1029')
    end

    it 'should match float with exponent terms' do
      token = @lexer.tokenise('10e23').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('10e23')
    end

    it 'should match float with negative exponent terms' do
      token = @lexer.tokenise('10e-23').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('10e-23')
    end

    it 'should match float with exponent terms' do
      token = @lexer.tokenise('1.234e5').first
      expect(token.type).to eq(:NUMBER)
      expect(token.value).to eq('1.234e5')
    end
  end

  context ':COMMENT' do
    it 'should match everything on a line after #' do
      token = @lexer.tokenise('foo # bar baz')[2]
      expect(token.type).to eq(:COMMENT)
      expect(token.value).to eq(' bar baz')
    end
  end

  context ':MLCOMMENT' do
    it 'should match comments on a single line' do
      token = @lexer.tokenise('/* foo bar */').first
      expect(token.type).to eq(:MLCOMMENT)
      expect(token.value).to eq('foo bar')
    end

    it 'should match comments on multiple lines' do
      token = @lexer.tokenise("/* foo\n * bar\n*/").first
      expect(token.type).to eq(:MLCOMMENT)
      expect(token.value).to eq("foo\n bar\n")
    end
  end

  context ':SLASH_COMMENT' do
    it 'should match everyone on a line after //' do
      token = @lexer.tokenise('foo // bar baz')[2]
      expect(token.type).to eq(:SLASH_COMMENT)
      expect(token.value).to eq(' bar baz')
    end
  end

  context ':SSTRING' do
    it 'should match a single quoted string' do
      token = @lexer.tokenise("'single quoted string'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string')
    end

    it "should match a single quoted string with an escaped '" do
      token = @lexer.tokenise(%q{'single quoted string with "\\'"'}).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\\'"')
    end

    it "should match a single quoted string with an escaped $" do
      token = @lexer.tokenise(%q{'single quoted string with "\$"'}).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\$"')
    end

    it "should match a single quoted string with an escaped ." do
      token = @lexer.tokenise(%q{'single quoted string with "\."'}).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\."')
    end

    it "should match a single quoted string with an escaped \\n" do
      token = @lexer.tokenise(%q{'single quoted string with "\n"'}).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\n"')
    end

    it "should match a single quoted string with an escaped \\" do
      token = @lexer.tokenise(%q{'single quoted string with "\\\\"'}).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\\\"')
    end

    it "should match an empty string" do
      token = @lexer.tokenise("''").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('')
    end

    it "should match an empty string ending with \\\\" do
      token = @lexer.tokenise("'foo\\\\'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq(%{foo\\\\})
    end
  end

  context ':REGEX' do
    it 'should match anything enclosed in //' do
      token = @lexer.tokenise('/this is a regex/').first
      expect(token.type).to eq(:REGEX)
      expect(token.value).to eq('this is a regex')
    end

    it 'should not match if there is \n in the regex' do
      token = @lexer.tokenise("/this is \n a regex/").first
      expect(token.type).to_not eq(:REGEX)
    end

    it 'should not consider \/ to be the end of the regex' do
      token = @lexer.tokenise('/this is \/ a regex/').first
      expect(token.type).to eq(:REGEX)
      expect(token.value).to eq('this is \\/ a regex')
    end

    it 'should be allowed as a param to a data type' do
      tokens = @lexer.tokenise('Foo[/bar/]')
      expect(tokens[2].type).to eq(:REGEX)
      expect(tokens[2].value).to eq('bar')
    end

    it 'should be allowed as a param to an optional data type' do
      tokens = @lexer.tokenise('Optional[Regexp[/^puppet/]]')
      expect(tokens[4].type).to eq(:REGEX)
      expect(tokens[4].value).to eq('^puppet')
    end

    it 'should not match chained division' do
      tokens = @lexer.tokenise('$x = $a/$b/$c')
      expect(tokens.select { |r| r.type == :REGEX }).to be_empty
    end
  end

  context ':STRING' do
    it 'should parse strings with \\\\\\' do
      expect {
        @lexer.tokenise("exec { \"/bin/echo \\\\\\\"${environment}\\\\\\\"\": }")
      }.to_not raise_error
    end
  end
end
