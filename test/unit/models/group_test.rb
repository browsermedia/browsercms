require File.join(File.dirname(__FILE__), '/../../test_helper')

class GroupTest < ActiveSupport::TestCase
  def test_valid
    assert Factory.build(:group).valid?
  end

  test "Find guest group via method" do
    expected = Cms::Group.find_by_code(Cms::Group::GUEST_CODE)
    assert_not_nil expected, "Validates that our fixture code is loading a guest user into the database."
    assert_equal expected, Cms::Group.guest
  end
end
