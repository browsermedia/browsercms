require File.join(File.dirname(__FILE__), '/../../test_helper')

class ConnectingTest < ActiveSupport::TestCase

  def setup
    @page = Factory(:page, :section => root_section)
    @block = Factory(:html_block, :name => "Versioned Content Block")
    @page.create_connector(@block, "main")
    reset(:page, :block)
  end

  test "Update connected pages should return true if there is a valid version." do
    block = HtmlBlock.new
    mock_draft = mock()
    mock_draft.expects(:version).returns(1)
    block.expects(:draft).returns(mock_draft)

    assert_equal true, block.update_connected_pages
  end

  test "Connected_to" do
    assert_equal 1, @block.version
    pages = Page.connected_to(:connectable => @block, :version => @block.version).all
    assert_equal @page, pages.first
  end
end