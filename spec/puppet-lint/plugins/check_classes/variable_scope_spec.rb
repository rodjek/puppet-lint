require 'spec_helper'

describe 'variable_scope' do
  let(:msg) { 'top-scope variable being used without an explicit namespace' }

  context 'class with no variables declared accessing top scope' do
    let(:code) { "
      class foo {
        $bar = $baz
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(16)
    end
  end

  context 'class with no variables declared accessing top scope explicitly' do
    let(:code) { "
      class foo {
        $bar = $::baz
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with no variables declared accessing local array index' do
    let(:code) { "
      class foo {
        $bar = ['one', 'two', 'three']
        $baz = $bar[1]
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with no variables declared accessing local hash key' do
    let(:code) { "
      class foo {
        $bar = {
          'one'   => 1,
          'two'   => 2,
          'three' => 3,
        }
        $baz = $bar['two']
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end


  context 'class with variables declared accessing local scope' do
    let(:code) { "
      class foo {
        $bar = 1
        $baz = $bar
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with parameters accessing local scope' do
    let(:code) { "
      class foo($bar='UNSET') {
        $baz = $bar
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'defined type with no variables declared accessing top scope' do
    let(:code) { "
      define foo() {
        $bar = $fqdn
      }"
    }

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(16)
    end
  end

  context 'defined type with no variables declared accessing top scope explicitly' do
    let(:code) { "
      define foo() {
        $bar = $::fqdn
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context '$name should be auto defined' do
    let(:code) { "
      define foo() {
        $bar = $name
        $baz = $title
        $gronk = $module_name
        $meep = $1
      }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with required parameter' do
    let(:code) { "
      define tomcat::base (
          $max_perm_gen,
          $owner = hiera('app_user'),
          $system_properties = {},
      ) {  }"
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'future parser blocks' do
    let(:code) { "
      class foo() {
        $foo = {1=>2, 3=>4}
        $foo.each |$a, $b| {
          $a    # should cause no warnings
          $c    # top-scope variable warning
        }
        $b      # top-scope variable warning
        $foo.each |$d| {
          $d[1] # should cause no warnings
        }
      }
    " }

    it 'should only detect two problems' do
      expect(problems).to have(2).problem
    end

    it 'should create two warnings' do
      expect(problems).to contain_warning(msg).on_line(8).in_column(9)
      expect(problems).to contain_warning(msg).on_line(6).in_column(11)
    end
  end

  %w{alias audit before loglevel noop notify require schedule stage subscribe tag}.each do |metaparam|
    context "referencing #{metaparam} metaparam value as a variable" do
      let(:code) { "
        class foo() {
          $#{metaparam}
        }
      " }

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end

  context 'support the use of facts and trusted facts for Puppet 3.5 onwards' do
    let(:code) { "
      class foo() {
        if $facts['osfamily'] == 'redhat' or $trusted['osfamily'] == 'redhat' {
         $redhat = true
        }
      }
    " }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
