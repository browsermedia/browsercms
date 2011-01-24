require_relative '../../test_helper'

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
  
  def test_determine_order
    assert_equal "foo", determine_order("foo desc", "foo desc")
    assert_equal "foo", determine_order("foo desc", "foo")
    assert_equal "foo desc", determine_order("foo", "foo desc")
    assert_equal "foo desc", determine_order("foo", "foo")
    assert_equal "bar desc", determine_order("foo", "bar desc")
    assert_equal "bar", determine_order("foo", "bar")
  end
  
  # returns content supplied to this method for testing
  def content_for(name, content = nil, &block)
    return name, content
  end
  def test_require_stylesheet_link_renders_to_correct_area
    stylesheet = 'site'
    stylesheet2 = 'site2'
    # default = :html_head
    assert_equal :html_head, require_stylesheet_link(stylesheet)[0]
    assert_equal :other_place, require_stylesheet_link(stylesheet2, :other_place)[0]
  end

  def test_require_stylesheet_link_renders_link_tag
    stylesheet = 'site'
    assert_equal stylesheet_link_tag(stylesheet), require_stylesheet_link(stylesheet)[1]
  end
  def test_require_stylesheet_link_renders_link_tags
    stylesheet = ['site','site2']
    assert_equal stylesheet_link_tag(stylesheet), require_stylesheet_link(stylesheet)[1]
  end
  def test_require_stylesheet_link_does_not_re_render_tag
    stylesheet = 'site'
    stylesheet2 = ['site','site2']
    require_stylesheet_link(stylesheet)
    assert_equal stylesheet_link_tag('site2'), require_stylesheet_link(stylesheet2)[1]    
  end
  def test_require_javascript_include_renders_to_correct_area
    js = 'site'
    js2 = 'site2'
    # default = :html_head
    assert_equal :html_head, require_javascript_include(js)[0]
    assert_equal :other_place, require_javascript_include(js2, :other_place)[0]
  end

  def test_require_javascript_include_renders_link_tag
    js = 'site'
    assert_equal javascript_include_tag(js), require_javascript_include(js)[1]
  end
  def test_require_javascript_include_renders_link_tags
    js = ['site','site2']
    assert_equal javascript_include_tag(js), require_javascript_include(js)[1]
  end
  def test_require_javascript_include_does_not_re_render_tag
    js = 'site'
    js2 = ['site','site2']
    require_javascript_include(js)
    assert_equal javascript_include_tag('site2'), require_javascript_include(js2)[1]    
  end
  
  
  
end

class Cms::ApplicationHelper::DeleteButtonTest < ActionView::TestCase
  include Cms::ApplicationHelper

  # Scenario: Delete Buttons should:

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
    expected_html = '<a href="#" class="button disabled delete_button http_delete confirm_with_title" id="delete_button" title="Really delete \'Server Error\'?"><span><span class="delete_img">&nbsp;</span>Delete</span></a>'
    assert_equal expected_html, delete_button(:title=>"Really delete \'Server Error\'?")
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