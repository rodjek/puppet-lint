require 'spec_helper'

describe 'selector_inside_resource' do
  let(:msg) { 'selector inside resource block' }

  context 'resource with a selector' do
    let(:code) do
      <<-END
        file { 'foo':
          ensure => $bar ? {
            true    => present,
            default => absent,
          },
        }
      END
    end

    it 'only detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(18)
    end
  end

  context 'resource with a variable as a attr value' do
    let(:code) do
      <<-END
        file { 'foo',
          ensure => $bar,
        }
      END
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
