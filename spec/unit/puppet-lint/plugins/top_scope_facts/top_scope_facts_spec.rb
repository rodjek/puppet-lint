require 'spec_helper'

describe 'top_scope_facts' do
  let(:msg) { 'top scope fact instead of facts hash' }

  context 'with fix disabled' do
    context 'fact variable using $facts hash' do
      let(:code) { "$facts['operatingsystem']" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'non-fact variable with two colons' do
      let(:code) { '$foo::bar' }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'top scope $::facts hash' do
      let(:code) { "$::facts['os']['family']" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'top scope $::trusted hash' do
      let(:code) { "$::trusted['certname']" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'fact variable using top scope' do
      let(:code) { '$::operatingsystem' }

      it 'onlies detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(1)
      end
    end

    context 'fact variable using top scope with curly braces in double quote' do
      let(:code) { '"${::operatingsystem}"' }

      it 'onlies detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(1).in_column(4)
      end
    end

    context 'out of scope namespaced variable with leading ::' do
      let(:code) { '$::profile::foo::bar' }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end

      context 'inside double quotes' do
        let(:code) { '"$::profile::foo::bar"' }

        it 'does not detect any problems' do
          expect(problems).to have(0).problem
        end
      end

      context 'with curly braces in double quote' do
        let(:code) { '"${::profile::foo::bar}"' }

        it 'does not detect any problems' do
          expect(problems).to have(0).problem
        end
      end
    end
  end

  context 'with fix enabled' do
    before(:each) do
      PuppetLint.configuration.fix = true
    end

    after(:each) do
      PuppetLint.configuration.fix = false
    end

    context 'fact variable using $facts hash' do
      let(:code) { "$facts['operatingsystem']" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'non-fact variable with two colons' do
      let(:code) { '$foo::bar' }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'top scope $::facts hash' do
      let(:code) { "$::facts['os']['family']" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'top scope $::trusted hash' do
      let(:code) { "$::trusted['certname']" }

      it 'does not detect any problems' do
        expect(problems).to have(0).problem
      end
    end

    context 'fact variable using top scope' do
      let(:code) { '$::operatingsystem' }

      it 'onlies detect a single problem' do
        expect(problems).to have(1).problem
      end

      it 'fixes the problem' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(1)
      end

      it 'shoulds use the facts hash' do
        expect(manifest).to eq("$facts['operatingsystem']")
      end
    end

    context 'fact variable using top scope with curly braces in double quote' do
      let(:code) { '"${::operatingsystem}"' }

      it 'fixes the problem' do
        expect(problems).to contain_fixed(msg).on_line(1).in_column(4)
      end

      it 'shoulds use the facts hash' do
        expect(manifest).to eq('"${facts[\'operatingsystem\']}"')
      end
    end

    context 'with custom top scope fact variables' do
      before(:each) do
        PuppetLint.configuration.top_scope_variables = ['location', 'role']
      end

      context 'fact variable using $facts hash' do
        let(:code) { "$facts['operatingsystem']" }

        it 'does not detect any problems' do
          expect(problems).to have(0).problem
        end
      end

      context 'fact variable using $trusted hash' do
        let(:code) { "$trusted['certname']" }

        it 'does not detect any problems' do
          expect(problems).to have(0).problem
        end
      end

      context 'whitelisted top scope variable $::location' do
        let(:code) { '$::location' }

        it 'does not detect any problems' do
          expect(problems).to have(0).problem
        end
      end

      context 'non-whitelisted top scope variable $::application' do
        let(:code) { '$::application' }

        it 'does not detect any problems' do
          expect(problems).to have(1).problem
        end
      end
    end
  end
end
