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

    test "Saves name and content for an HtmlBlock" do
      b = create(:html_block, name: "Old block name", content: "Old Content")
      @page.add_content(b)
      @page.save!
      msg_payload = {
          "blocks" => {
              "Cms::HtmlBlock" => {
                  b.id => {
                      "content" => {"type" => "full", "value" => "New Content"},
                      "name" => {"type" => "simple", "value" => "New Name"}
                  }
              }
          }}
      add_page_title(msg_payload)
      c = PageComponent.new(@page.id, msg_payload)
      c.save

      updated_block = HtmlBlock.find(b.id).draft
      assert_equal "New Name", updated_block.name
      assert_equal "New Content", updated_block.content
    end

    private
    # page_title is required. This is a pseudo factory for testing.
    def add_page_title(msg)
      msg["page_title"] = {"type" => "simple", "data" => {}, "value" => "New Title"}
    end
  end


end