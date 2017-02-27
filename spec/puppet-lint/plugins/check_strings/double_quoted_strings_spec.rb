require 'spec_helper'

describe 'double_quoted_strings' do
  let(:msg) { 'double quoted string containing no variables' }

  context 'with fix disabled' do
    context 'double quoted string containing a variable inside single quotes' do
      let(:code) { "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'multiple strings in a line' do
      let(:code) { "\"aoeu\" '${foo}'" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(1)
      end
    end

    context 'double quoted string nested in a single quoted string' do
      let(:code) { "'grep \"status=sent\" /var/log/mail.log'" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'double quoted string after a comment' do
      let(:code) { "service { 'foo': } # \"bar\"" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'double quoted string containing newline but no variables' do
      let(:code) { %{"foo\n"} }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'double quoted string with backslash for continuation' do
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

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'double quoted true' do
      let(:code) { "class { 'foo': boolFlag => \"true\" }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(28)
      end
    end

    context 'double quoted false' do
      let(:code) { "class { 'foo': boolFlag => \"false\" }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(28)
      end
    end

    context 'double quoted stings containing supported escape patterns' do
      let(:code) {%{
        $string1 = "this string contins \n newline"
        $string2 = "this string contains \ttab"
        $string3 = "this string contains \${escaped} var"
        $string4 = "this string contains \\"escaped \\" double quotes"
        $string5 = "this string contains \\'escaped \\' single quotes"
        $string6 = "this string contains \r line return"
        $string7 = "this string contains \\\\ an escaped backslash"
        }}

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'double quoted string with random escape should be rejected' do
      let(:code) {%{ $ztring = "this string contains \l random esape" } }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(12)
      end
    end

    context 'single quotes in a double quoted string' do
      let(:code) { "\"this 'string' 'has' lots of 'quotes'\"" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'double quoted string containing single quoted string' do
      let(:code) { %[notify { "'foo'": }] }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'double quoted string containing a variable inside single quotes' do
      let(:code) { "exec { \"/usr/bin/wget -O - '${source}' | /usr/bin/apt-key add -\": }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'double quoted string containing a lone dollar' do
      let(:code) {"\"sed -i 's/^;*[[:space:]]*${name}[[:space:]]*=.*$/${name} = ${value}/g' file\"" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end

    context 'multiple strings in a line' do
      let(:code) { "\"aoeu\" '${foo}'" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'should fix the manifest' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'should convert the double quoted string into single quotes' do
        expect(manifest).to eq("'aoeu' '${foo}'")
      end
    end

    context 'single quotes in a double quoted string' do
      let(:code) { "\"this 'string' 'has' lots of 'quotes'\"" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end

      it 'should not modify the manifest' do
        expect(manifest).to eq(code)
      end
    end
  end
end
