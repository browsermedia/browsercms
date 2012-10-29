require 'test_helper'

class Cms::ApplicationHelperTest < ActionView::TestCase
  
  def test_url_with_mode
    [
      [["http://localhost:3000", "edit"], "?mode=edit"],
      [["http://localhost:3000/", "edit"], "/?mode=edit"],
      [["http://localhost:3000/foo", "edit"], "/foo?mode=edit"],
      [["http://localhost:3000/foo?bar=1", "edit"], "/foo?bar=1&mode=edit"],
      [["http://localhost:3000/foo?mode=view", "edit"], "/foo?mode=edit"],
      [["http://localhost:3000/foo?bar=1&mode=view", "edit"], "/foo?bar=1&mode=edit"],
      [["http://localhost:3000/foo?other_mode=1&mode=view", "edit"], "/foo?other_mode=1&mode=edit"],
      [["/foo?other_mode=1&mode=view", "edit"], "/foo?other_mode=1&mode=edit"]
    ].each do |args, expected|
      assert_equal expected, url_with_mode(*args)
    end
  end
  
  test "url_with_mode should handle 'blank' referers as empty" do
    assert_equal("?mode=edit", url_with_mode("", "edit"))
    assert_equal("?mode=edit", url_with_mode(nil, "edit"))
  end
  
  def test_determine_order
    assert_equal "foo", determine_order("foo desc", "foo desc")
    assert_equal "foo", determine_order("foo desc", "foo")
    assert_equal "foo desc", determine_order("foo", "foo desc")
    assert_equal "foo desc", determine_order("foo", "foo")
    assert_equal "bar desc", determine_order("foo", "bar desc")
    assert_equal "bar", determine_order("foo", "bar")
  end

  test "Convert jquery selector to dashs" do
    s = "input.something"
    assert_equal "input_something", s.gsub(".", "_")

    assert_equal "input_something", send(:to_id, s)
    assert_equal "input_something_uncheck", send(:to_id, s, "uncheck")
  end
end

class Cms::ApplicationHelper::DeleteButtonTest < ActionView::TestCase
  include Cms::ApplicationHelper
  include Cms::UiElementsHelper

  test "generate a button without an explicit title by default" do
    expected_html = '<a href="#" class="button disabled delete_button" id="delete_button"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button
  end

  test "use a standard Confirm link if :title option is specified" do
    expected_html = '<a href="#" class="button disabled delete_button http_delete confirm_with_title" id="delete_button"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button(:title=>true)
  end  
  
  test "take :path attribute if specified" do
    expected_html = '<a href="/cms/html_blocks/3" class="button disabled delete_button" id="delete_button"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button(:path=>"/cms/html_blocks/3")
  end

  test "Writes out title if specified as a string" do
    expected_html = '<a href="#" class="button disabled delete_button http_delete confirm_with_title" id="delete_button" title="Really delete Server Error?"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button(:title=>"Really delete Server Error?")
  end

  test "default to disabled, but have an :enabled option" do
    expected_html = '<a href="#" class="button disabled delete_button" id="delete_button"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button

    expected_html = '<a href="#" class="button disabled delete_button" id="delete_button"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button(:enabled=>false)

    expected_html = '<a href="#" class="button delete_button" id="delete_button"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button(:enabled=>true)
  end
end

class Cms::ApplicationHelper::EditButtonTest < ActionView::TestCase
  include Cms::ApplicationHelper

  # Scenario: Edit Buttons should:

  test "generate a button without an explicit title by default" do
    expected_html = '<a href="#" class="button disabled" id="edit_button"><span>&nbsp;Edit&nbsp;</span></a>'
    assert_equal expected_html, edit_button
  end


end

class Cms::ApplicationHelper::AddButtonTest < ActionView::TestCase
  include Cms::ApplicationHelper

  # Scenario: Add Buttons should:

  test "generate a button without an explicit title by default" do
    expected_html = '<a href="/cms/page_routes/new" class="button"><span>&nbsp;Add&nbsp;</span></a>'
    assert_equal expected_html, add_button("/cms/page_routes/new")
  end


end