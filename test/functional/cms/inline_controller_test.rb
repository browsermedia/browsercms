require 'test_helper'

module Cms
  class InlineContentControllerTest < ActionController::TestCase

    test "filter html from page_title" do
      assert_equal "Remove", ActionView::Base.full_sanitizer.sanitize("<p>Remove</p>")
    end
  end
end
