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
  
end
