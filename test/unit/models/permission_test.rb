require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  def test_create
    perm = create(:permission, :name => "test")
    assert !build(:permission, :name => "").valid?
    assert !build(:permission, :name => "test").valid?
    assert_equal perm, Cms::Permission.named("test").first
  end
end
