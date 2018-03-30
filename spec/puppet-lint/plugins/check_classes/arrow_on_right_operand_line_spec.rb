require 'spec_helper'

describe 'arrow_on_right_operand_line' do
  msg = "arrow should be on the right operand's line"

  { 'chain' => '->', 'subscribe chain' => '~>' }.each do |name, operator|
    context "#{name} operator" do
      context 'both operands on same line' do
        let(:code) do
          <<-END
            Package['httpd'] #{operator} Service['httpd']
          END
        end

        it 'should not detect any problems' do
          expect(problems).to have(0).problems
        end
      end

      context 'arrow on the line of left operand' do
        let(:code) do
          <<-END
            Package['httpd']  #{operator}
            Service['httpd']
          END
        end

        it 'should detect a problem' do
          expect(problems).to have(1).problem
        end

        it 'should create a warning' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(31)
        end

        context 'with fix enabled' do
          before do
            PuppetLint.configuration.fix = true
          end

          after do
            PuppetLint.configuration.fix = false
          end

          let(:fixed) do
            <<-END.gsub(%r{^ {2}}, '')
              Package['httpd']
              #{operator} Service['httpd']
            END
          end

          it 'should fix the problem' do
            expect(problems).to contain_fixed(msg).on_line(1).in_column(31)
          end

          it 'should move the arrow to before the right operand' do
            expect(manifest).to eq(fixed)
          end
        end
      end

      context 'arrow on the line of right operand' do
        let(:code) do
          <<-END
            Package['httpd']
            #{operator} Service['httpd']
          END
        end

        it 'should not detect any problems' do
          expect(problems).to have(0).problems
        end
      end

      context 'arrow on the line of left operand with comment in between' do
        let(:code) do
          <<-END
            Package['httpd'] #{operator}

            # a comment
            # another comment
            Service['httpd']
          END
        end

        it 'should detect a problem' do
          expect(problems).to have(1).problem
        end

        it 'should create a warning' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(30)
        end

        context 'with fix enabled' do
          before(:each) do
            PuppetLint.configuration.fix = true
          end

          after(:each) do
            PuppetLint.configuration.fix = false
          end

          let(:fixed) do
            <<-END.gsub(%r{^ {2}}, '')
              Package['httpd']

              # a comment
              # another comment
              #{operator} Service['httpd']
            END
          end

          it 'should fix the problem' do
            expect(problems).to contain_fixed(msg).on_line(1).in_column(30)
          end

          it 'should move the arrow to before the right operand' do
            expect(manifest).to eq(fixed)
          end
        end
      end

      context 'arrow on the line of the left operand with a comment following the arrow' do
        let(:code) do
          <<-END
            Package['httpd'] #{operator} # something
            Service['httpd']
          END
        end

        it 'should detect a problem' do
          expect(problems).to have(1).problem
        end

        it 'should create a warning' do
          expect(problems).to contain_warning(msg).on_line(1).in_column(30)
        end

        context 'with fix enabled' do
          before(:each) do
            PuppetLint.configuration.fix = true
          end

          after(:each) do
            PuppetLint.configuration.fix = false
          end

          let(:fixed) do
            <<-END.gsub(%r{^ {2}}, '')
              Package['httpd'] # something
              #{operator} Service['httpd']
            END
          end

          it 'should fix the problem' do
            expect(problems).to contain_fixed(msg).on_line(1).in_column(30)
          end

          it 'should move the arrow to before the right operand' do
            expect(manifest).to eq(fixed)
          end
        end
      end
    end
  end
end
