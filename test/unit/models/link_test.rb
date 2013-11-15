require 'test_helper'

class LinkTest < ActiveSupport::TestCase

  def setup
    @link = create(:link)
    @another_link = create(:link)
  end

  def test_create
    assert build(:link).valid?
    assert !build(:link, :name => "").valid?
  end

  test "draft_version is stored on pages" do
    assert_equal 1, @link.version
    assert_equal 1, @link.latest_version
  end

  test "#update increments the latest_version" do
    @link.name = "New"
    @link.save_draft
    @link.reload

    assert_equal 1, @link.version
    assert_equal 2, @link.latest_version

    assert_equal 1, @another_link.reload.latest_version, "Should only update its own version, not other tables"
  end

  test "live?" do
    assert @link.live?
  end

  test "updating makes it not live" do
    @link.update(:name => "New", :publish_on_save => false)
    @link.reload
    refute @link.live?

    @link.publish!
    @link.reload
    assert @link.live?
  end

  test "live? as_of_version" do
    @link.update_attributes(:name => "New")
    @link.publish!

    v1 = @link.as_of_version(1)
    assert v1.live?
  end
end