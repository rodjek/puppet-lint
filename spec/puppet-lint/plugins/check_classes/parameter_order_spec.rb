require 'spec_helper'

describe 'parameter_order' do
  let(:msg) { 'optional parameter listed before required parameter' }

  context 'define with attrs in order' do
    let(:code) { "define foo($bar, $baz='gronk') { }" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with parameter that calls a function' do
    let(:code) { "define foo($bar=extlookup($name)) {}" }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with attrs out of order' do
    let(:code) { "define foo($bar='baz', $gronk) { }" }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(24)
    end
  end

  context 'class/define parameter set to another variable' do
    let(:code) { "
      define foo($bar, $baz = $name, $gronk=$::fqdn) {
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class/define parameter set to another variable with incorrect order' do
    let(:code) { "
      define foo($baz = $name, $bar, $gronk=$::fqdn) {
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(32)
    end
  end

  context 'issue-101' do
    let(:code) { "
      define b (
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
