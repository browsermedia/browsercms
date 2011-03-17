require 'test_helper'

# Tests the BrowserCMS extentions to the String class
class StringTest < ActiveSupport::TestCase

  test "string should be pluralizes unless there is one" do
    assert_equal "posts", "post".pluralize_unless_one(0)
    assert_equal "posts", "post".pluralize_unless_one(2)
  end

  test "string shouldn't be pluralized if there is one" do
    assert_equal "post", "post".pluralize_unless_one(1)
  end
end