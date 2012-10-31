require "test_helper"

module Cms
  class PageComponentsTest < ActiveSupport::TestCase

    def setup
      @page = create(:page, name: "Old Title")
    end

    test "Verify Sample JSON format works" do
      a = MultiJson.load('[{"content" : {"page_title" : "New Title"}}]')
      assert_equal "content", a.first.keys.first
    end

    test "Assignment from params" do
      c = PageComponent.new(@page.id, {"page_title" => {"type" => "simple", "data" => {}, "value" => "Testing"}})
      assert_equal "Testing", c.page_title[:value]
      assert_equal @page.id, c.page_id
    end

    test "Save update to page" do
      c = PageComponent.new(@page.id, {"page_title" => {"type" => "simple", "data" => {}, "value" => "New Title"}})
      assert c.save, "Should save"
      assert_equal "New Title", Page.find(@page.id).draft.title
    end
  end
end