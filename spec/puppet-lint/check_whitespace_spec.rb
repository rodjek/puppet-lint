require 'spec_helper'

describe PuppetLint::Plugins::CheckWhitespace do
  subject do
    klass = described_class.new
    klass.test(code)
    klass
  end

  describe 'selectors inside a resource' do
    let(:code) { "
      file { 'foo':
        ensure  => $ensure,
        require => $ensure ? {
          present => Class['tomcat::install'],
          absent  => undef,
        },
      }"
    }

    its(:warnings) { should be_empty }
    its(:errors) { should be_empty }
  end
end
