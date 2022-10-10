require 'spec_helper'

describe 'case_without_default' do
  let(:msg) { 'case statement without a default case' }

  context 'case statement with a default case' do
    let(:code) do
      <<-END
        case $foo {
          bar: { }
          default: { }
        }
      END
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'case statement without a default case' do
    let(:code) do
      <<-END
        case $foo {
          bar: { }
          baz: { }
        }
      END
    end

    it 'only detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(9)
    end
  end

  context 'nested case statements without a default case on the outermost' do
    let(:code) do
      <<-END
        case $foo {
          case $foop {
            bar: {}
            default: {}
          }
        }
      END
    end

    it 'only detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(msg)
    end
  end

  context 'three nested case statements with two missing default cases' do
    let(:code) do
      <<-END
        case $foo {
          case $foop {
            bar: {}
            case $woop {
              baz: {}
            }
            default: {}
          }
        }
      END
    end

    it 'detects two problems' do
      expect(problems).to have(2).problems
    end

    it 'creates two warnings' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(9)
      expect(problems).to contain_warning(msg).on_line(4).in_column(13)
    end
  end

  context 'issue-117' do
    let(:code) do
      <<-END
        $mem = inline_template('<%
          mem,unit = scope.lookupvar(\'::memorysize\').split
          mem = mem.to_f
          # Normalize mem to bytes
          case unit
              when nil:  mem *= (1<<0)
              when \'kB\': mem *= (1<<10)
              when \'MB\': mem *= (1<<20)
              when \'GB\': mem *= (1<<30)
              when \'TB\': mem *= (1<<40)
          end
          %><%= mem.to_i %>')
      END
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'issue-829 nested selector with default in case without default' do
    let(:code) do
      <<-END
        case $::operatingsystem {
          'centos': {
            $variable = $::operatingsystemmajrelease ? {
              '7'     => 'value1'
              default => 'value2',
            }
          }
        }
      END
    end

    it 'creates one warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(9)
    end
  end

  context 'issue-829 nested selector with default in case with default' do
    let(:code) do
      <<-END
        case $::operatingsystem {
          'centos': {
            $variable = $::operatingsystemmajrelease ? {
              '7'     => 'value1'
              default => 'value2',
            }
          }
          default: {}
        }
      END
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
