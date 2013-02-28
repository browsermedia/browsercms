require 'test_helper'

module Cms
  class InlineContentControllerTest < ActionController::TestCase

    test "filter html from page_title" do
      assert_equal "Remove", HTML::FullSanitizer.new.sanitize("<p>Remove</p>")
    end

    test "For page_title we should strip leading paragraphs" do
      controller = InlineContentController.new
      params = {content: {title: "<p>Test</p>"}, content_name: "page"}
      controller.expects(:params).returns(params).at_least_once

      assert_equal({title: "Test"}, controller.send(:filtered_content))
    end
  end
end
