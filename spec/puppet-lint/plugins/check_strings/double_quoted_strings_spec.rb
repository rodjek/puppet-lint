require 'spec_helper'

describe 'double_quoted_strings' do
  describe 'double quoted string containing a variable inside single quotes' do
    let(:code) { "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }" }

    its(:problems) { should be_empty }
  end

  describe 'double quoted string containing a variable inside single quotes w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }" }

    its(:problems) { should be_empty }
    its(:manifest) {
      should == "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }"
    }
  end

  describe 'double quoted string containing a lone dollar w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) {"\"sed -i 's/^;*[[:space:]]*${name}[[:space:]]*=.*$/${name} = ${value}/g' file\"" }

    its(:problems) { should be_empty }
    its(:manifest) {
      should == "\"sed -i 's/^;*[[:space:]]*${name}[[:space:]]*=.*$/${name} = ${value}/g' file\""
    }
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

  describe 'multiple strings in a line w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "\"aoeu\" '${foo}'" }

    its(:problems) {
      should have_problem({
        :kind       => :fixed,
        :message    => 'double quoted string containing no variables',
        :linenumber => 1,
        :column     => 1,
      })
    }
    its(:manifest) { should == "'aoeu' '${foo}'" }
  end

  describe 'double quoted string nested in a single quoted string' do
    let(:code) { "'grep \"status=sent\" /var/log/mail.log'" }

    its(:problems) { should be_empty }
  end

  describe 'double quoted string after a comment' do
    let(:code) { "service { 'foo': } # \"bar\"" }

    its(:problems) { should be_empty }
  end

  describe 'double quoted stings containing supported escape patterns' do
    let(:code) {%{
      $string1 = "this string contins \n newline"
      $string2 = "this string contains \ttab"
      $string3 = "this string contains \${escaped} var"
      $string4 = "this string contains \\"escaped \\" double quotes"
      $string5 = "this string contains \\'escaped \\' single quotes"
      $string6 = "this string contains \r line return"
      }}
    its (:problems) { should == [] }
  end

  describe 'double quoted string with random escape should be rejected' do
    let(:code) {%{ $ztring = "this string contains \l random esape" } }
    its (:problems) {
      should have_problem({
        :kind       => :warning,
        :message    => 'double quoted string containing no variables',
        :linenumber => 1,
        :column     => 12,
      })
    }
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
