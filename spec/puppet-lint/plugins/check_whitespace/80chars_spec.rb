# encoding: utf-8
require 'spec_helper'

describe '80chars' do
  describe 'file resource with a source line > 80c' do
    let(:code) { "
      file {
        source  => 'puppet:///modules/certificates/etc/ssl/private/wildcard.example.com.crt',
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'length of lines with UTF-8 characters' do
    let(:code) { "
      # ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
      # ┃          Configuration           ┃
      # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    }
    its(:problems) {
      should be_empty
    }
  end

  describe '81 character line' do
    let(:code) { 'a' * 81 }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => 'line has more than 80 characters',
        :linenumber => 1,
        :column     => 80,
      })
    }
  end
end
