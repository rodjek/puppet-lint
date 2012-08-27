require 'spec_helper'

describe 'file_mode' do
  describe '3 digit file mode' do
    let(:code) { "file { 'foo': mode => '777' }" }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "mode should be represented as a 4 digit octal value or symbolic mode", :linenumber => 1
    }
  end

  describe '4 digit file mode' do
    let(:code) { "file { 'foo': mode => '0777' }" }

    its(:problems) { should be_empty }
  end

  describe 'file mode as a variable' do
    let(:code) { "file { 'foo': mode => $file_mode }" }

    its(:problems) { should be_empty }
  end

  describe 'symbolic file mode' do
    let(:code) { "file { 'foo': mode => 'u=rw,og=r' }" }

    its(:problems) { should be_empty }
  end

  describe 'file mode undef unquoted' do
    let(:code) { "file { 'foo': mode => undef }" }

    its(:problems) { should be_empty }
  end

  describe 'file mode undef quoted' do
    let(:code) { "file { 'foo': mode => 'undef' }" }

    its(:problems) {
      should only_have_problem :kind => :warning, :message => "mode should be represented as a 4 digit octal value or symbolic mode", :linenumber => 1
    }
  end
end
