# encoding: utf-8
require 'spec_helper'

describe '80chars' do
  before do
    PuppetLint.configuration.send("enable_80chars")
  end

  let(:msg) { 'line has more than 80 characters' }

  context 'file resource with a source line > 80c' do
    let(:code) { "
      file {
        source  => 'puppet:///modules/certificates/etc/ssl/private/wildcard.example.com.crt',
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'file resource with a template line > 80c' do
    let(:code) { "
      file {
        content => template('mymodule/this/is/a/truely/absurdly/long/path/that/should/make/you/feel/bad'),
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'length of lines with UTF-8 characters' do
    let(:code) { "
      # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
      # ┃          Configuration           ┃
      # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context '81 character line' do
    let(:code) { 'a' * 81 }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(80)
    end
  end

# TODO: figure out why rspec keeps enabling this check!
#
#   context '81 character line with disabled check' do
#     let(:code) { 'a' * 81 }
#
#     PuppetLint.configuration.send("disable_80chars")
#
#     it 'should not detect any problems' do
#       expect(problems).to have(0).problem
#     end
#   end

end
