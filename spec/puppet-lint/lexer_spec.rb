# encoding: utf-8

require 'spec_helper'

describe PuppetLint::Lexer do # rubocop:disable Metrics/BlockLength
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
      token = @lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(1)
    end

    it 'should get correct line number after double quoted multi line string' do
      @lexer.new_token(:STRING, "test\ntest")
      token = @lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'should get correct line number after a multi line comment' do
      @lexer.new_token(:MLCOMMENT, "test\ntest", :raw => "/*test\ntest*/")
      token = @lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'should calculate the line number for a multi line string' do
      @lexer.new_token(:SSTRING, "test\ntest")
      token = @lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'should calculate line number for string that ends with newline' do
      @lexer.new_token(:SSTRING, "test\n")
      token = @lexer.new_token(:TEST, 'test')
      expect(token.line).to eq(2)
    end

    it 'should calculate the column number for an empty string' do
      token = @lexer.new_token(:TEST, 'test')
      expect(token.column).to eq(1)
    end

    it 'should calculate the column number for a single line string' do
      @lexer.new_token(:SSTRING, 'this is a test')
      token = @lexer.new_token(:TEST, 'test')
      expect(token.column).to eq(17)
    end

    it 'should calculate the column number for a multi line string' do
      @lexer.instance_variable_set('@line_no', 4)
      @lexer.instance_variable_set('@column', 5)
      @lexer.new_token(:SSTRING, "test\ntest")
      token = @lexer.new_token(:TEST, 'test')
      expect(token.column).to eq(6)
    end
  end

  describe '#slurp_string' do
    it 'raises a LexerError if the string is not terminated' do
      expect {
        @lexer.slurp_string('unterminated string')
      }.to raise_error(PuppetLint::LexerError)
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
      @lexer.interpolate_string('foo bar baz"', 1, 1)
      token = @lexer.tokens.first

      expect(@lexer.tokens.length).to eq(1)
      expect(token.type).to eq(:STRING)
      expect(token.value).to eq('foo bar baz')
      expect(token.line).to eq(1)
      expect(token.column).to eq(1)
    end

    it 'should handle a string with a newline' do
      @lexer.interpolate_string(%(foo\nbar"), 1, 1)
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

    it 'should handle a string with newline characters' do
      # rubocop:disable Layout/TrailingWhitespace
      manifest = <<END
  exec {
    'do-something':
      command     => "echo > /home/bar/.token; 
                                kdestroy; 
                                kinit ${pseudouser}@EXAMPLE.COM -kt ${keytab_path}; 
                                test $(klist | egrep '^Default principal:' | sed 's/Default principal:\s//') = '${pseudouser}'@EXAMPLE.COM",
      refreshonly => true;
  }
END
      # rubocop:enable Layout/TrailingWhitespace
      tokens = @lexer.tokenise(manifest)

      expect(tokens.length).to eq(36)

      expect(tokens[0].type).to eq(:WHITESPACE)
      expect(tokens[0].value).to eq('  ')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:NAME)
      expect(tokens[1].value).to eq('exec')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(3)
      expect(tokens[2].type).to eq(:WHITESPACE)
      expect(tokens[2].value).to eq(' ')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(7)
      expect(tokens[3].type).to eq(:LBRACE)
      expect(tokens[3].value).to eq('{')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(8)
      expect(tokens[4].type).to eq(:NEWLINE)
      expect(tokens[4].value).to eq("\n")
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(9)
      expect(tokens[5].type).to eq(:INDENT)
      expect(tokens[5].value).to eq('    ')
      expect(tokens[5].line).to eq(2)
      expect(tokens[5].column).to eq(1)
      expect(tokens[6].type).to eq(:SSTRING)
      expect(tokens[6].value).to eq('do-something')
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(5)
      expect(tokens[7].type).to eq(:COLON)
      expect(tokens[7].value).to eq(':')
      expect(tokens[7].line).to eq(2)
      expect(tokens[7].column).to eq(19)
      expect(tokens[8].type).to eq(:NEWLINE)
      expect(tokens[8].value).to eq("\n")
      expect(tokens[8].line).to eq(2)
      expect(tokens[8].column).to eq(20)
      expect(tokens[9].type).to eq(:INDENT)
      expect(tokens[9].value).to eq('      ')
      expect(tokens[9].line).to eq(3)
      expect(tokens[9].column).to eq(1)
      expect(tokens[10].type).to eq(:NAME)
      expect(tokens[10].value).to eq('command')
      expect(tokens[10].line).to eq(3)
      expect(tokens[10].column).to eq(7)
      expect(tokens[11].type).to eq(:WHITESPACE)
      expect(tokens[11].value).to eq('     ')
      expect(tokens[11].line).to eq(3)
      expect(tokens[11].column).to eq(14)
      expect(tokens[12].type).to eq(:FARROW)
      expect(tokens[12].value).to eq('=>')
      expect(tokens[12].line).to eq(3)
      expect(tokens[12].column).to eq(19)
      expect(tokens[13].type).to eq(:WHITESPACE)
      expect(tokens[13].value).to eq(' ')
      expect(tokens[13].line).to eq(3)
      expect(tokens[13].column).to eq(21)
      expect(tokens[14].type).to eq(:DQPRE)
      expect(tokens[14].value).to eq("echo > /home/bar/.token; \n                                kdestroy; \n                                kinit ")
      expect(tokens[14].line).to eq(3)
      expect(tokens[14].column).to eq(22)
      expect(tokens[15].type).to eq(:VARIABLE)
      expect(tokens[15].value).to eq('pseudouser')
      expect(tokens[15].line).to eq(5)
      expect(tokens[15].column).to eq(131)
      expect(tokens[16].type).to eq(:DQMID)
      expect(tokens[16].value).to eq('@EXAMPLE.COM -kt ')
      expect(tokens[16].line).to eq(5)
      expect(tokens[16].column).to eq(143)
      expect(tokens[17].type).to eq(:VARIABLE)
      expect(tokens[17].value).to eq('keytab_path')
      expect(tokens[17].line).to eq(5)
      expect(tokens[17].column).to eq(161)
      expect(tokens[18].type).to eq(:DQMID)
      expect(tokens[18].value).to eq("; \n                                test ")
      expect(tokens[18].line).to eq(5)
      expect(tokens[18].column).to eq(174)
      expect(tokens[19].type).to eq(:DQMID)
      expect(tokens[19].value).to eq('$')
      expect(tokens[19].line).to eq(6)
      expect(tokens[19].column).to eq(213)
      expect(tokens[20].type).to eq(:DQMID)
      expect(tokens[20].value).to eq("(klist | egrep '^Default principal:' | sed 's/Default principal: //') = '")
      expect(tokens[20].line).to eq(6)
      expect(tokens[20].column).to eq(215)
      expect(tokens[21].type).to eq(:VARIABLE)
      expect(tokens[21].value).to eq('pseudouser')
      expect(tokens[21].line).to eq(6)
      expect(tokens[21].column).to eq(289)
      expect(tokens[22].type).to eq(:DQPOST)
      expect(tokens[22].value).to eq("'@EXAMPLE.COM")
      expect(tokens[22].line).to eq(6)
      expect(tokens[22].column).to eq(301)
      expect(tokens[23].type).to eq(:COMMA)
      expect(tokens[23].value).to eq(',')
      expect(tokens[23].line).to eq(6)
      expect(tokens[23].column).to eq(315)
      expect(tokens[24].type).to eq(:NEWLINE)
      expect(tokens[24].value).to eq("\n")
      expect(tokens[24].line).to eq(6)
      expect(tokens[24].column).to eq(316)
      expect(tokens[25].type).to eq(:INDENT)
      expect(tokens[25].value).to eq('      ')
      expect(tokens[25].line).to eq(7)
      expect(tokens[25].column).to eq(1)
      expect(tokens[26].type).to eq(:NAME)
      expect(tokens[26].value).to eq('refreshonly')
      expect(tokens[26].line).to eq(7)
      expect(tokens[26].column).to eq(7)
      expect(tokens[27].type).to eq(:WHITESPACE)
      expect(tokens[27].value).to eq(' ')
      expect(tokens[27].line).to eq(7)
      expect(tokens[27].column).to eq(18)
      expect(tokens[28].type).to eq(:FARROW)
      expect(tokens[28].value).to eq('=>')
      expect(tokens[28].line).to eq(7)
      expect(tokens[28].column).to eq(19)
      expect(tokens[29].type).to eq(:WHITESPACE)
      expect(tokens[29].value).to eq(' ')
      expect(tokens[29].line).to eq(7)
      expect(tokens[29].column).to eq(21)
      expect(tokens[30].type).to eq(:TRUE)
      expect(tokens[30].value).to eq('true')
      expect(tokens[30].line).to eq(7)
      expect(tokens[30].column).to eq(22)
      expect(tokens[31].type).to eq(:SEMIC)
      expect(tokens[31].value).to eq(';')
      expect(tokens[31].line).to eq(7)
      expect(tokens[31].column).to eq(26)
      expect(tokens[32].type).to eq(:NEWLINE)
      expect(tokens[32].value).to eq("\n")
      expect(tokens[32].line).to eq(7)
      expect(tokens[32].column).to eq(27)
      expect(tokens[33].type).to eq(:INDENT)
      expect(tokens[33].value).to eq('  ')
      expect(tokens[33].line).to eq(8)
      expect(tokens[33].column).to eq(1)
      expect(tokens[34].type).to eq(:RBRACE)
      expect(tokens[34].value).to eq('}')
      expect(tokens[34].line).to eq(8)
      expect(tokens[34].column).to eq(3)
      expect(tokens[35].type).to eq(:NEWLINE)
      expect(tokens[35].value).to eq("\n")
      expect(tokens[35].line).to eq(8)
      expect(tokens[35].column).to eq(4)
    end

    it 'should handle a string with a single variable and newline characters' do
      manifest = <<-END
    foo
    /bin/${foo} >>
    /bar/baz"
      END
      @lexer.interpolate_string(manifest, 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq("    foo\n    /bin/")
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('foo')
      expect(tokens[1].line).to eq(2)
      expect(tokens[1].column).to eq(20)

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq(" >>\n    /bar/baz")
      expect(tokens[2].line).to eq(2)
      expect(tokens[2].column).to eq(25)
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
      expect(tokens[1].to_manifest).to eq('bar')

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(8)

      expect(tokens.map(&:to_manifest).join('')).to eq('"${bar}"')
    end

    it 'should not remove the unnecessary $ from enclosed variables' do
      tokens = @lexer.tokenise('"${$bar}"')

      expect(tokens.length).to eq(3)

      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)

      expect(tokens[1].type).to eq(:VARIABLE)
      expect(tokens[1].value).to eq('bar')
      expect(tokens[1].raw).to eq('$bar')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(4)
      expect(tokens[1].to_manifest).to eq('$bar')

      expect(tokens[2].type).to eq(:DQPOST)
      expect(tokens[2].value).to eq('')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(9)

      expect(tokens.map(&:to_manifest).join('')).to eq('"${$bar}"')
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
      @lexer.interpolate_string(%q(string with ${'a nested single quoted string'} inside it"), 1, 1)
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
      @lexer.interpolate_string('string with ${(3+5)/4} nested math"', 1, 1)
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
      @lexer.interpolate_string(%q(string with ${['an array ', $v2]} in it"), 1, 1)
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
      @lexer.interpolate_string('$$$$"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(1)

      expect(tokens[0].type).to eq(:STRING)
      expect(tokens[0].value).to eq('$$$$')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
    end

    it 'should handle "$foo$bar"' do
      @lexer.interpolate_string('$foo$bar"', 1, 1)
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
      @lexer.interpolate_string('foo$bar$"', 1, 1)
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
      @lexer.interpolate_string('foo$$bar"', 1, 1)
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
      @lexer.interpolate_string('"', 1, 1)
      tokens = @lexer.tokens

      expect(tokens.length).to eq(1)

      expect(tokens[0].type).to eq(:STRING)
      expect(tokens[0].value).to eq('')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
    end

    it 'should handle "$foo::::bar"' do
      @lexer.interpolate_string('$foo::::bar"', 1, 1)
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

    it 'should calculate the column number correctly after an enclosed variable' do
      token = @lexer.tokenise('  "${foo}" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(12)
    end

    it 'should calculate the column number correctly after an enclosed variable starting with a string' do
      token = @lexer.tokenise('  "bar${foo}" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(15)
    end

    it 'should calculate the column number correctly after an enclosed variable ending with a string' do
      token = @lexer.tokenise('  "${foo}bar" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(15)
    end

    it 'should calculate the column number correctly after an enclosed variable surround by a string' do
      token = @lexer.tokenise('  "foo${bar}baz" =>').last
      expect(token.type).to eq(:FARROW)
      expect(token.column).to eq(18)
    end

    it 'should not enclose variable with a chained function call' do
      manifest = '"This is ${a.test}"'
      tokens = @lexer.tokenise(manifest)
      expect(tokens.map(&:to_manifest).join('')).to eq(manifest)
    end
  end

  %w[
    case
    class
    default
    define
    import
    if
    elsif
    else
    inherits
    node
    and
    or
    undef
    true
    false
    in
    unless
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
    it "should have a token named '#{name}'" do
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

  context ':HEREDOC without interpolation' do
    it 'should parse a simple heredoc' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @(myheredoc)
        SOMETHING
        ELSE
        :
        |-myheredoc
      END
      tokens = @lexer.tokenise(manifest)

      expect(tokens.length).to eq(8)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('myheredoc')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(20)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  SOMETHING\n  ELSE\n  :\n  ")
      expect(tokens[6].raw).to eq("  SOMETHING\n  ELSE\n  :\n  |-myheredoc")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(14)
    end

    it 'should not interpolate the contents of the heredoc' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @(myheredoc)
        SOMETHING
        ${else}
        :
        |-myheredoc
      END
      tokens = @lexer.tokenise(manifest)

      expect(tokens.length).to eq(8)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('myheredoc')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(20)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  SOMETHING\n  ${else}\n  :\n  ")
      expect(tokens[6].raw).to eq("  SOMETHING\n  ${else}\n  :\n  |-myheredoc")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].value).to eq("\n")
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(14)
    end

    it 'should handle multiple heredoc declarations on a single line' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = "${@(end1)} ${@(end2)}"
        foo
        |-end1
        bar
        |-end2
      END
      tokens = @lexer.tokenise(manifest)

      expect(tokens.length).to eq(14)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:DQPRE)
      expect(tokens[4].value).to eq('')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:HEREDOC_OPEN)
      expect(tokens[5].value).to eq('end1')
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(11)
      expect(tokens[6].type).to eq(:DQMID)
      expect(tokens[6].value).to eq(' ')
      expect(tokens[6].line).to eq(1)
      expect(tokens[6].column).to eq(19)
      expect(tokens[7].type).to eq(:HEREDOC_OPEN)
      expect(tokens[7].value).to eq('end2')
      expect(tokens[7].line).to eq(1)
      expect(tokens[7].column).to eq(22)
      expect(tokens[8].type).to eq(:DQPOST)
      expect(tokens[8].value).to eq('')
      expect(tokens[8].line).to eq(1)
      expect(tokens[8].column).to eq(30)
      expect(tokens[9].type).to eq(:NEWLINE)
      expect(tokens[9].value).to eq("\n")
      expect(tokens[9].line).to eq(1)
      expect(tokens[9].column).to eq(31)
      expect(tokens[10].type).to eq(:HEREDOC)
      expect(tokens[10].value).to eq("  foo\n  ")
      expect(tokens[10].raw).to eq("  foo\n  |-end1")
      expect(tokens[10].line).to eq(2)
      expect(tokens[10].column).to eq(1)
      expect(tokens[11].type).to eq(:NEWLINE)
      expect(tokens[11].value).to eq("\n")
      expect(tokens[11].line).to eq(3)
      expect(tokens[11].column).to eq(9)
      expect(tokens[12].type).to eq(:HEREDOC)
      expect(tokens[12].value).to eq("  bar\n  ")
      expect(tokens[12].raw).to eq("  bar\n  |-end2")
      expect(tokens[12].line).to eq(4)
      expect(tokens[12].column).to eq(1)
      expect(tokens[13].type).to eq(:NEWLINE)
      expect(tokens[13].value).to eq("\n")
      expect(tokens[13].line).to eq(5)
      expect(tokens[13].column).to eq(9)
    end

    it 'should handle a heredoc that specifies a syntax' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("end":json/)
        {
          "foo": "bar"
        }
        |-end
      END

      tokens = @lexer.tokenise(manifest)

      expect(tokens.length).to eq(8)
      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('"end":json/')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(22)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  {\n    \"foo\": \"bar\"\n  }\n  ")
      expect(tokens[6].raw).to eq("  {\n    \"foo\": \"bar\"\n  }\n  |-end")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].value).to eq("\n")
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(8)
    end
  end

  context ':HEREDOC with interpolation' do
    it 'should parse a heredoc with no interpolated values as a :HEREDOC' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("myheredoc"/)
        SOMETHING
        ELSE
        :
        |-myheredoc
      END
      tokens = @lexer.tokenise(manifest)

      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('"myheredoc"/')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(23)
      expect(tokens[6].type).to eq(:HEREDOC)
      expect(tokens[6].value).to eq("  SOMETHING\n  ELSE\n  :\n  ")
      expect(tokens[6].raw).to eq("  SOMETHING\n  ELSE\n  :\n  |-myheredoc")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:NEWLINE)
      expect(tokens[7].value).to eq("\n")
      expect(tokens[7].line).to eq(5)
      expect(tokens[7].column).to eq(14)
    end

    it 'should parse a heredoc with interpolated values' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("myheredoc"/)
        SOMETHING
        ${else}
        AND :
        $another
        THING
        | myheredoc
      END

      tokens = @lexer.tokenise(manifest)
      expect(tokens.map(&:to_manifest).join('')).to eq(manifest)

      expect(tokens[0].type).to eq(:VARIABLE)
      expect(tokens[0].value).to eq('str')
      expect(tokens[0].line).to eq(1)
      expect(tokens[0].column).to eq(1)
      expect(tokens[1].type).to eq(:WHITESPACE)
      expect(tokens[1].value).to eq(' ')
      expect(tokens[1].line).to eq(1)
      expect(tokens[1].column).to eq(5)
      expect(tokens[2].type).to eq(:EQUALS)
      expect(tokens[2].value).to eq('=')
      expect(tokens[2].line).to eq(1)
      expect(tokens[2].column).to eq(6)
      expect(tokens[3].type).to eq(:WHITESPACE)
      expect(tokens[3].value).to eq(' ')
      expect(tokens[3].line).to eq(1)
      expect(tokens[3].column).to eq(7)
      expect(tokens[4].type).to eq(:HEREDOC_OPEN)
      expect(tokens[4].value).to eq('"myheredoc"/')
      expect(tokens[4].line).to eq(1)
      expect(tokens[4].column).to eq(8)
      expect(tokens[5].type).to eq(:NEWLINE)
      expect(tokens[5].value).to eq("\n")
      expect(tokens[5].line).to eq(1)
      expect(tokens[5].column).to eq(23)
      expect(tokens[6].type).to eq(:HEREDOC_PRE)
      expect(tokens[6].value).to eq("  SOMETHING\n  ")
      expect(tokens[6].line).to eq(2)
      expect(tokens[6].column).to eq(1)
      expect(tokens[7].type).to eq(:VARIABLE)
      expect(tokens[7].value).to eq('else')
      expect(tokens[7].line).to eq(3)
      expect(tokens[7].column).to eq(5)
      expect(tokens[7].to_manifest).to eq('else')
      expect(tokens[8].type).to eq(:HEREDOC_MID)
      expect(tokens[8].value).to eq("\n  AND :\n  ")
      expect(tokens[8].line).to eq(3)
      expect(tokens[8].column).to eq(9)
      expect(tokens[8].to_manifest).to eq("}\n  AND :\n  ")
      expect(tokens[9].type).to eq(:UNENC_VARIABLE)
      expect(tokens[9].value).to eq('another')
      expect(tokens[9].line).to eq(5)
      expect(tokens[9].column).to eq(3)
      expect(tokens[9].to_manifest).to eq('$another')
      expect(tokens[10].type).to eq(:HEREDOC_POST)
      expect(tokens[10].value).to eq("\n  THING\n  ")
      expect(tokens[10].raw).to eq("\n  THING\n  | myheredoc")
      expect(tokens[10].line).to eq(5)
      expect(tokens[10].column).to eq(11)
    end

    it 'should not remove the unnecessary $ from enclosed variables' do
      manifest = <<-END.gsub(%r{^ {6}}, '')
      $str = @("myheredoc"/)
        ${$myvar}
        |-myheredoc
      END
      tokens = @lexer.tokenise(manifest)

      expect(tokens.length).to eq(10)

      expect(tokens[7].type).to eq(:VARIABLE)
      expect(tokens[7].value).to eq('myvar')
      expect(tokens[7].raw).to eq('$myvar')
      expect(tokens[7].to_manifest).to eq('$myvar')

      expect(tokens.map(&:to_manifest).join('')).to eq(manifest)
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

    it 'should match terms that start with Types' do
      token = @lexer.tokenise('Regexp_foo').first
      expect(token.type).to eq(:CLASSREF)
      expect(token.value).to eq('Regexp_foo')
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

    it 'should match barewords beginning with an underscore' do
      token = @lexer.tokenise('_bareword').first
      expect(token.type).to eq(:NAME)
      expect(token.value).to eq('_bareword')
    end
  end

  context ':FUNCTION_NAME' do
    it 'should match when a :NAME is followed by a :LPAREN' do
      token = @lexer.tokenise('my_function(').first
      expect(token.type).to eq(:FUNCTION_NAME)
      expect(token.value).to eq('my_function')
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

    it 'should not include DOS line endings in the comment value' do
      tokens = @lexer.tokenise("foo # bar baz\r\n")

      expect(tokens[2]).to have_attributes(:type => :COMMENT, :value => ' bar baz')
      expect(tokens[3]).to have_attributes(:type => :NEWLINE, :value => "\r\n")
    end

    it 'should not include Unix line endings in the comment value' do
      tokens = @lexer.tokenise("foo # bar baz\n")

      expect(tokens[2]).to have_attributes(:type => :COMMENT, :value => ' bar baz')
      expect(tokens[3]).to have_attributes(:type => :NEWLINE, :value => "\n")
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

    it 'should not include DOS line endings in the comment value' do
      tokens = @lexer.tokenise("foo // bar baz\r\n")

      expect(tokens[2]).to have_attributes(:type => :SLASH_COMMENT, :value => ' bar baz')
      expect(tokens[3]).to have_attributes(:type => :NEWLINE, :value => "\r\n")
    end

    it 'should not include Unix line endings in the comment value' do
      tokens = @lexer.tokenise("foo // bar baz\n")

      expect(tokens[2]).to have_attributes(:type => :SLASH_COMMENT, :value => ' bar baz')
      expect(tokens[3]).to have_attributes(:type => :NEWLINE, :value => "\n")
    end
  end

  context ':SSTRING' do
    it 'should match a single quoted string' do
      token = @lexer.tokenise("'single quoted string'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string')
    end

    it "should match a single quoted string with an escaped '" do
      token = @lexer.tokenise(%q('single quoted string with "\\'"')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\\'"')
    end

    it 'should match a single quoted string with an escaped $' do
      token = @lexer.tokenise(%q('single quoted string with "\$"')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\$"')
    end

    it 'should match a single quoted string with an escaped .' do
      token = @lexer.tokenise(%q('single quoted string with "\."')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\."')
    end

    it 'should match a single quoted string with an escaped \\n' do
      token = @lexer.tokenise(%q('single quoted string with "\n"')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\n"')
    end

    it 'should match a single quoted string with an escaped \\' do
      token = @lexer.tokenise(%q('single quoted string with "\\\\"')).first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('single quoted string with "\\\\"')
    end

    it 'should match an empty string' do
      token = @lexer.tokenise("''").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq('')
    end

    it 'should match an empty string ending with \\\\' do
      token = @lexer.tokenise("'foo\\\\'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq(%(foo\\\\))
    end

    it 'should match single quoted string containing a line break' do
      token = @lexer.tokenise("'\n'").first
      expect(token.type).to eq(:SSTRING)
      expect(token.value).to eq("\n")
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

    it 'should properly parse when regex follows an if' do
      tokens = @lexer.tokenise('if /^icinga_service_icon_.*/ in $location_info { }')
      expect(tokens[2].type).to eq(:REGEX)
    end

    it 'should properly parse when a regex follows an elsif' do
      tokens = @lexer.tokenise('if /a/ in $location_info { } elsif /b/ in $location_info { }')
      expect(tokens[2].type).to eq(:REGEX)
      expect(tokens[14].type).to eq(:REGEX)
    end

    it 'should properly parse when a regex is provided as a function argument' do
      tokens = @lexer.tokenise('$somevar = $other_var.match(/([\w\.]+(:\d+)?(\/\w+)?)(:(\w+))?/)')
      expect(tokens[8].type).to eq(:REGEX)
      expect(tokens[8].value).to eq('([\w\.]+(:\d+)?(\/\w+)?)(:(\w+))?')
    end
  end

  context ':STRING' do
    it 'should parse strings with embedded strings' do
      expect {
        @lexer.tokenise('exec { "/bin/echo \"${environment}\"": }')
      }.to_not raise_error
    end

    it 'should match double quoted string containing a line break' do
      token = @lexer.tokenise(%("\n")).first
      expect(token.type).to eq(:STRING)
      expect(token.value).to eq("\n")
    end

    it 'should handle interpolated values that contain double quotes' do
      manifest = %{"export bar=\\"${join(hiera('test'), "," )}\\""}

      tokens = @lexer.tokenise(manifest)
      expect(tokens[0].type).to eq(:DQPRE)
      expect(tokens[0].value).to eq('export bar=\"')
      expect(tokens[1].type).to eq(:FUNCTION_NAME)
      expect(tokens[1].value).to eq('join')
      expect(tokens[2].type).to eq(:LPAREN)
      expect(tokens[3].type).to eq(:FUNCTION_NAME)
      expect(tokens[3].value).to eq('hiera')
      expect(tokens[4].type).to eq(:LPAREN)
      expect(tokens[5].type).to eq(:SSTRING)
      expect(tokens[5].value).to eq('test')
      expect(tokens[6].type).to eq(:RPAREN)
      expect(tokens[7].type).to eq(:COMMA)
      expect(tokens[8].type).to eq(:WHITESPACE)
      expect(tokens[8].value).to eq(' ')
      expect(tokens[9].type).to eq(:STRING)
      expect(tokens[9].value).to eq(',')
      expect(tokens[10].type).to eq(:WHITESPACE)
      expect(tokens[10].value).to eq(' ')
      expect(tokens[11].type).to eq(:RPAREN)
      expect(tokens[12].type).to eq(:DQPOST)
      expect(tokens[12].value).to eq('\"')
    end
  end

  context ':WHITESPACE' do
    it 'should parse spaces' do
      token = @lexer.tokenise(' ').first
      expect(token.type).to eq(:WHITESPACE)
      expect(token.value).to eq(' ')
    end

    it 'should parse tabs' do
      token = @lexer.tokenise("\t").first
      expect(token.type).to eq(:WHITESPACE)
      expect(token.value).to eq("\t")
    end

    it 'should parse unicode spaces', :unless => RUBY_VERSION == '1.8.7' do
      token = @lexer.tokenise("\xc2\xa0").first
      expect(token.type).to eq(:WHITESPACE)
      expect(token.value).to eq("\xc2\xa0")
    end
  end
end
