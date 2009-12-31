require File.join(File.dirname(__FILE__), '/../../test_helper')

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
