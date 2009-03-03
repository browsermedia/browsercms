require File.join(File.dirname(__FILE__), '/../../test_helper')

class PermissionTest < ActiveSupport::TestCase
  def test_create
    perm = Factory(:permission, :name => "test")
    assert !Factory.build(:permission, :name => "").valid?
    assert !Factory.build(:permission, :name => "test").valid?
    assert_equal perm, Permission.named("test").first
  end
end