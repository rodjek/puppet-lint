require 'spec_helper'

describe 'parameter_order' do
  let(:msg) { 'optional parameter listed before required parameter' }

  %w[define class].each do |type|
    context "#{type} with attrs in order" do
      let(:code) { "#{type} foo($bar, $baz='gronk') { }" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context "#{type} with parameter that calls a function" do
      let(:code) { "#{type} foo($bar=extlookup($name)) {}" }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context "#{type} with attrs out of order" do
      let(:code) { "#{type} foo($bar='baz', $gronk) { }" }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      col = (type == 'class' ? 23 : 24)
      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(col)
      end
    end

    context "#{type} parameter set to another variable" do
      let(:code) do
        <<-END
          #{type} foo($bar, $baz = $name, $gronk=$::fqdn) {
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context "#{type} parameter set to another variable with incorrect order" do
      let(:code) do
        <<-END
          #{type} foo($baz = $name, $bar, $gronk=$::fqdn) {
          }
        END
      end

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      col = (type == 'class' ? 35 : 36)
      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(col)
      end
    end

    context 'issue-101' do
      let(:code) do
        <<-END
          #{type} b (
            $foo,
            $bar='',
            $baz={}
          ) { }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context "#{type} parameter w/a hash containing a variable and no optional parameters" do
      let(:code) do
        <<-END
          $var1 = 'test'

          #{type} test (
            $entries = {
              '200 xxx' => {
                param1 => $var1,
                param2 => 'value2',
                param3 => 'value3',
              }
            },
            $mandatory => undef,
          ) { }
        END
      end

      it { expect(problems).to have(0).problem }
    end

    context "#{type} parameter w/a hash containing a variable followed by an optional parameter" do
      let(:code) do
        <<-END
          $var1 = 'test'

          #{type} test (
            $entries = {
              '200 xxx' => {
                param1 => $var1,
                param2 => 'value2',
                param3 => 'value3',
              }
            },
            $optional,
            $mandatory => undef,
          ) { }
        END
      end

      it { expect(problems).to contain_warning(msg).on_line(11).in_column(13) }
    end

    context "#{type} parameter w/array containing a variable" do
      let(:code) do
        <<-END
          #{type} test (
            $var1 = [$::hostname, 'host'],
          ) { }
        END
      end

      it { expect(problems).to have(0).problem }
    end

    context "#{type} parameter with Optional data type" do
      let(:code) do
        <<-END
          #{type} test(
            String $test = 'value',
            Optional[String] $optional,
          ) { }
        END
      end

      it { expect(problems).to have(0).problems }
    end
  end
end
