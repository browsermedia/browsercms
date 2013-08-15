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

class Cms::ApplicationHelper::EditButtonTest < ActionView::TestCase
  include Cms::ApplicationHelper

  # Scenario: Edit Buttons should:

  test "generate a button without an explicit title by default" do
    expected_html = '<a class="button disabled" href="#" id="edit_button"><span>&nbsp;Edit&nbsp;</span></a>'
    assert_equal expected_html, edit_button
  end


end

class Cms::ApplicationHelper::AddButtonTest < ActionView::TestCase
  include Cms::ApplicationHelper

  # Scenario: Add Buttons should:

  test "generate a button without an explicit title by default" do
    expected_html = '<a class="button" href="/cms/page_routes/new"><span>&nbsp;Add&nbsp;</span></a>'
    assert_equal expected_html, add_button("/cms/page_routes/new")
  end


end