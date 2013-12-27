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

class LinkAccessiblityTest < ActiveSupport::TestCase

    def public_sections
      [public_section]
    end

    def public_section
      @public_section ||= create(:public_section)
    end

    def protected_section
      @protected_section ||= create(:protected_section)
    end

    test "accessible_to_guests?" do
      public_link = create(:link, parent: public_section)
      assert public_link.accessible_to_guests?(public_sections, public_section)
    end

    test "pages in restricted sections are not accessible_to_guests?" do
      protected_link = create(:link, parent: protected_section)
      refute protected_link.accessible_to_guests?(public_sections, protected_section)
    end
  end