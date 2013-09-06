require 'test_helper'

module Cms
  class InlineContentControllerTest < ActionController::TestCase

    test "filter html from page_title" do
      assert_equal "Remove", HTML::FullSanitizer.new.sanitize("<p>Remove</p>")
    end
  end
end
