require 'test_helper'

class LinkTest < ActiveSupport::TestCase

  test "should have namespaced table" do
    assert_equal true, Cms::Link.namespaced_table?
  end

  def test_create
    assert Factory.build(:link).valid?
    assert !Factory.build(:link, :name => "").valid?
  end
end