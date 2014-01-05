require 'spec_helper'

describe 'user_instead_of_owner' do
  describe 'user field should cause a warning' do
    let(:code) { "file { 'foo': user => :root }" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => "file resource doesn't use user field; use owner instead",
        :linenumber => 1,
        :column     => 15,
      })
    end
  end

  describe 'owner field should not cause a problem' do
    let(:code) { "file { 'foo': owner => :root }" }

    its(:problems) do
      should be_empty
    end
  end

  describe 'user and owner should still cause a warning' do
    let(:code) { "file { 'foo': user => :root, owner => :root }" }

    its(:problems) do
      should only_have_problem({
        :kind       => :warning,
        :message    => "file resource doesn't use user field; use owner instead",
        :linenumber => 1,
        :column     => 15,
      })
    end
  end
end
