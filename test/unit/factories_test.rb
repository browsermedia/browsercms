require "test_helper"

class FactoriesTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  # Write tests to verify the basic Factories are being used correctly.
  # Make :task work, such that a valid task is created with assignee/assigner that can edit.
  # Use in tasks_controller rather than massive setup code.
  #
  # Bonus points...
  # Refactor test_helper to get rid of adhoc setup code.
  # Split factories into 'sharable' cms factories (that can be used in testing BrowserCMS projects).
  #   as well as 'core' CMS factories (needed only for core)
  test "content_editor_group" do
    group = create(:content_editor_group)
    assert_equal Cms::Group, group.class
  end

  test ":content_editor factory has edit_permission" do
    editor = create(:content_editor)
    assert editor.able_to?(:edit_content)
    assert editor.able_to?(:publish_content)
  end

  test "section" do
    section = create(:section)
    assert_equal "Test", section.name
    assert_equal "/test", section.path
    assert_not_nil section.parent
  end

  test "cms_admin_user" do
    user = create(:cms_admin)
    assert_equal 1, user.groups.size
    assert_equal true, user.able_to?(:edit_content)
    assert_equal true, user.able_to?(:administrate)
    assert_equal true, user.able_to?(:publish_content)
  end

  test ":public_page is also published" do
    assert_equal true, create(:public_page).published?
  end
end