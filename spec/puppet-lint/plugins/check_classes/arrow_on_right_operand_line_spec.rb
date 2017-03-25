require 'spec_helper'

describe 'arrow_on_right_operand_line' do
  {'chain' => '->', 'subscribe chain' => '~>'}.each do |name, operator|
    context "#{name} operator" do
      context 'both operands on same line' do
        let(:code) { "Package['httpd'] #{operator} Service['httpd']" }

        it { expect(problems).to have(0).problems }
      end

      context 'arrow on the line of left operand' do
        let(:code) do
          "Package['httpd']  #{operator}
            Service['httpd']"
        end

        it { expect(problems).to have(1).problems }

        context 'with fix enabled' do
          before do
            PuppetLint.configuration.fix = true
          end

          after do
            PuppetLint.configuration.fix = false
          end

          let(:fixed) do
            "Package['httpd']
            #{operator} Service['httpd']"
          end

          it { expect(manifest).to eq (fixed) }
        end
      end

      context 'arrow on the line of right operand' do
        let(:code) { "Package['httpd']
          #{operator} Service['httpd']" }

        it { expect(problems).to have(0).problems }
      end
    end
  end
end
