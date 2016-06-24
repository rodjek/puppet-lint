require 'spec_helper'

describe 'parameter_order' do
  let(:msg) { 'optional parameter listed before required parameter' }

  ['define', 'class'].each do |type|
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

      col = (type == "class" ? 23 : 24)
      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(col)
      end
    end

    context "#{type} parameter set to another variable" do
      let(:code) { "
        #{type} foo($bar, $baz = $name, $gronk=$::fqdn) {
        }"
      }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context "#{type} parameter set to another variable with incorrect order" do
      let(:code) { "
        #{type} foo($baz = $name, $bar, $gronk=$::fqdn) {
        }"
      }

      it 'should only detect a single problem' do
        expect(problems).to have(1).problem
      end

      col = (type == "class" ? 33 : 34)
      it 'should create a warning' do
        expect(problems).to contain_warning(msg).on_line(2).in_column(col)
      end
    end

    context 'issue-101' do
      let(:code) { "
        #{type} b (
          $foo,
          $bar='',
          $baz={}
        ) { }
      " }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end
end
