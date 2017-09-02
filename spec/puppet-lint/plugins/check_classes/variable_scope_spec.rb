require 'spec_helper'

describe 'variable_scope' do
  let(:msg) { 'top-scope variable being used without an explicit namespace' }

  context 'class with no variables declared accessing top scope' do
    let(:code) do
      <<-END
        class foo {
          $bar = $baz
        }
      END
    end

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(18)
    end
  end

  context 'class with no variables declared accessing top scope explicitly' do
    let(:code) do
      <<-END
        class foo {
          $bar = $::baz
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with no variables declared accessing local array index' do
    let(:code) do
      <<-END
        class foo {
          $bar = ['one', 'two', 'three']
          $baz = $bar[1]
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with no variables declared accessing local hash key' do
    let(:code) do
      <<-END
        class foo {
          $bar = {
            'one'   => 1,
            'two'   => 2,
            'three' => 3,
          }
          $baz = $bar['two']
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with variables declared accessing local scope' do
    let(:code) do
      <<-END
        class foo {
          $bar = 1
          $baz = $bar
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with parameters accessing local scope' do
    let(:code) do
      <<-END
        class foo($bar='UNSET') {
          $baz = $bar
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'defined type with no variables declared accessing top scope' do
    let(:code) do
      <<-END
        define foo() {
          $bar = $fqdn
        }
      END
    end

    it 'should only detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(18)
    end
  end

  context 'defined type with no variables declared accessing top scope explicitly' do
    let(:code) do
      <<-END
        define foo() {
          $bar = $::fqdn
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context '$name should be auto defined' do
    let(:code) do
      <<-END
        define foo() {
          $bar = $name
          $baz = $title
          $gronk = $module_name
          $meep = $1
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with required parameter' do
    let(:code) do
      <<-END
        define tomcat::base (
            $max_perm_gen,
            $owner = hiera('app_user'),
            $system_properties = {},
        ) {  }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'future parser blocks' do
    let(:code) do
      <<-END
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
      END
    end

    it 'should only detect two problems' do
      expect(problems).to have(2).problem
    end

    it 'should create two warnings' do
      expect(problems).to contain_warning(msg).on_line(7).in_column(11)
      expect(problems).to contain_warning(msg).on_line(5).in_column(13)
    end
  end

  context 'nested future parser blocks' do
    let(:code) do
      <<-END
        class foo() {
          $foo = {1=>2, 3=>4}
          $bar = [1, 2, 3]
          $foo.each |$k ,$v| {
            $k
            $v
            $x  # top-scope warning
            $bar.each |$x| {
              $k
              $v
              $x
              $p  # top-scope warning
            }
            $x  # top-scope warning
          }
        }
      END
    end

    it 'should only detect three problems' do
      expect(problems).to have(3).problem
    end

    it 'should create three warnings' do
      expect(problems).to contain_warning(msg).on_line(7).in_column(13)
      expect(problems).to contain_warning(msg).on_line(12).in_column(15)
      expect(problems).to contain_warning(msg).on_line(14).in_column(13)
    end
  end

  %w[alias audit before loglevel noop notify require schedule stage subscribe tag].each do |metaparam|
    context "referencing #{metaparam} metaparam value as a variable" do
      let(:code) do
        <<-END
          class foo() {
            $#{metaparam}
          }
        END
      end

      it 'should not detect any problems' do
        expect(problems).to have(0).problems
      end
    end
  end

  context 'support the use of facts and trusted facts for Puppet 3.5 onwards' do
    let(:code) do
      <<-END
        class foo() {
          if $facts['osfamily'] == 'redhat' or $trusted['osfamily'] == 'redhat' {
           $redhat = true
          }
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'multiple left hand variable assign' do
    let(:code) do
      <<-END
        class test {
          [$foo, $bar] = something()
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'nested variable assignment' do
    let(:code) do
      <<-END
        class test {
          [$foo, [[$bar, $baz], $qux]] = something()
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'function calls inside string interpolation' do
    let(:code) do
      <<-END
        class test {
          "${split('1,2,3', ',')}"  # split is a function
          "${lookup('foo::bar')}"  # lookup is a function
        }
      END
    end

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'variables in string interpolation' do
    let(:code) do
      <<-END
        class test {
          "${foo.split(',')}"  # foo is a top-scope variable
          "${::bar.split(',')}"
        }
      END
    end

    it 'should only detect one problem' do
      expect(problems).to have(1).problems
    end

    it 'should create one warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(13)
    end
  end
end
