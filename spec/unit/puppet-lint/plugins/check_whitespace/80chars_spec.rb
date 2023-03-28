# encoding: utf-8

require 'spec_helper'

describe '80chars' do
  before(:each) do
    PuppetLint.configuration.send(:enable_80chars)
  end

  let(:msg) { 'line has more than 80 characters' }

  context 'file resource with a source line > 80c' do
    let(:code) do
      <<-END
        file {
          source  => 'puppet:///modules/certificates/etc/ssl/private/wildcard.example.com.crt',
        }
      END
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'file resource with a template line > 80c' do
    let(:code) do
      <<-END
        file {
          content => template('mymodule/this/is/a/truely/absurdly/long/path/that/should/make/you/feel/bad'),
        }
      END
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'length of lines with UTF-8 characters' do
    let(:code) do
      <<-END
        # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
        # ┃          Configuration           ┃
        # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
      END
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context '81 character line' do
    let(:code) { 'a' * 81 }

    it 'only detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(80)
    end
  end
end
