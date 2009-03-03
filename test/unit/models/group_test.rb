require File.join(File.dirname(__FILE__), '/../../test_helper')

class GroupTest < ActiveSupport::TestCase
  def test_valid
    assert Factory.build(:group).valid?
  end
end