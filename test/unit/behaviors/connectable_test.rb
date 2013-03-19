require "test_helper"

module Cms

  class ConnectableTest < ActiveSupport::TestCase

    def setup
      given_a_site_exists
      @block = create(:html_block)
      @connected_page = create(:public_page, :parent => root_section)
      @connected_page_2 = create(:public_page, :parent => root_section)
      @unconnected_page = create(:public_page, :parent => root_section)

      @connected_page.create_connector(@block, "main")
      @connected_page_2.create_connector(@block, "main")
    end

    def teardown
    end

    test "#connected_pages" do
      assert_equal [@connected_page, @connected_page_2], @block.connected_pages
    end

    test "#connected_pages should return same list when called twice" do
      expected = @block.connected_pages
      assert_equal expected.object_id, @block.connected_pages.object_id
    end

    test ".supports_inline_editing?" do
      assert @block.supports_inline_editing?
    end

    test ".supports_inline_editing? shouldn't be true for portlet subclasses'" do
      refute LoginPortlet.new.supports_inline_editing?
    end
  end
end