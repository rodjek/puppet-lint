# encoding: utf-8
require 'spec_helper'

describe '140chars' do
  let(:msg) { 'line has more than 140 characters' }

  context 'file resource with a source line > 140c' do
    let(:code) { "
      file {
        source  => 'puppet:///modules/certificates/etc/ssl/private/wildcard.example.com.crt',
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'file resource with a template line > 140c' do
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

  context '141 character line' do
    let(:code) { 'a' * 141 }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(140)
    end
  end
end
