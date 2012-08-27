require 'spec_helper'

describe 'double_quoted_strings' do
  describe 'double quoted string containing a variable inside single quotes' do
    let(:code) { "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }" }

    its(:problems) { should be_empty }
  end

  describe 'multiple strings in a line' do
    let(:code) { "\"aoeu\" '${foo}'" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => 'double quoted string containing no variables',
        :linenumber => 1,
        :column     => 1,
      })
    }
  end

  describe 'double quoted string nested in a single quoted string' do
    let(:code) { "'grep \"status=sent\" /var/log/mail.log'" }

    its(:problems) { should be_empty }
  end

  describe 'double quoted string after a comment' do
    let(:code) { "service { 'foo': } # \"bar\"" }

    its(:problems) { should be_empty }
  end

  describe 'double quoted string containing newline but no variables' do
    let(:code) { %{"foo\n"} }

    its(:problems) { should be_empty }
  end

  describe 'double quoted string with backslash for continuation' do
    let(:code) { %{
      class puppet::master::maintenance (
      ) {
        cron { 'puppet_master_reports_cleanup':
          command     => "/usr/bin/find /var/lib/puppet/reports -type f -mtime +15 \
                         -delete && /usr/bin/find /var/lib/puppet/reports -mindepth 1 \
                         -empty -type d -delete",
          minute      => '15',
          hour        => '5',
        }
      }
    } }

    its(:problems) { should == [] }
  end

  describe 'double quoted true' do
    let(:code) { "class { 'foo': boolFlag => \"true\" }" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => 'double quoted string containing no variables',
        :linenumber => 1,
        :column     => 28,
      })
    }
  end

  describe 'double quoted false' do
    let(:code) { "class { 'foo': boolFlag => \"false\" }" }

    its(:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => 'double quoted string containing no variables',
        :linenumber => 1,
        :column     => 28,
      })
    }
  end
end
