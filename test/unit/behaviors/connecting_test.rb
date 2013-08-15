require 'test_helper'

module Cms
  class Thing < ActiveRecord::Base
    is_connectable
  end
end
class ConnectingTest < ActiveSupport::TestCase

  def setup
    @page = create(:page, :section => root_section)
    @block = create(:html_block, :name => "Versioned Content Block")
    @page.create_connector(@block, "main")
    reset(:page, :block)
  end

  test "Class have display_names" do
    assert_equal "Thing", Cms::Thing.display_name
  end

  test "Default Naming Strategy" do
    assert_equal "String", Cms::Behaviors::Connecting.default_naming_for(String)

    module Cms::SomeModule
      class Thing ; end
    end
    assert_equal "Thing", Cms::Behaviors::Connecting.default_naming_for(Cms::SomeModule::Thing)
  end
  test "Update connected pages should return true if there is a valid version." do
    block = Cms::HtmlBlock.new
    mock_draft = mock()
    mock_draft.expects(:version).returns(1)
    block.expects(:draft).returns(mock_draft)

    assert_equal true, block.update_connected_pages
  end

  test "Connected_to" do
    assert_equal 1, @block.version
    pages = Cms::Page.connected_to(:connectable => @block, :version => @block.version).to_a
    assert_equal @page, pages.first
  end

  test "connected_pages should return all pages connected to a versioned block " do
    @page.publish!
    assert_equal [@page], @block.connected_pages
  end


  test "connected_pages should return all pages connected to a nonversioned block " do
    @portlet = create(:portlet)
    @page.create_connector(@portlet, "main")
    @page.publish!
    assert_equal [@page], @portlet.connected_pages
  end
end