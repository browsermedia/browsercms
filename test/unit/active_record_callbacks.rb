require File.join(File.dirname(__FILE__), '/../test_helper')

class ActiveRecordCallbacksTest < ActiveSupport::TestCase

#  test "When callbacks occur" do
#    b = HtmlBlock.new(:name=>"NAME")
#    assert b.save
#  end

  def setup
    @page = create(:page, :section => root_section)
    @block = create(:html_block, :name => "Versioned Content Block")
    @page.create_connector(@block, "main")
    reset(:page, :block)
  end

  # Copy back to content_block_test if there are any changes.
#  def test_editing_connected_to_an_unpublished_page
#    page_version_count = Page::Version.count
#    assert_equal 2, @page.versions.size, "Should be two versions of the page"
#    assert !@page.published?
#
#    pages = Page.connected_to(:connectable => @block, :version => @block.version).all
#    assert_equal [@page], pages, "block should be connected to page"
#
#
#    assert @block.update_attributes(:name => "something different")
#    assert_equal false, @block.skip_callbacks
#    assert_equal 2, @block.versions.size, "should be two versions of this block"
#    reset(:page)
#
#
#    assert !@page.published?
#    assert_equal 3, @page.versions.size, "Should be three versions of the page."
#    assert_equal 3, @page.draft.version, "Draft version of page should be updated to v3 since its connected to the updated block."
#    assert_incremented page_version_count, Page::Version.count
#    assert_match /^HtmlBlock #\d+ was Edited/, @page.draft.version_comment
#
#    conns = @block.connectors.all(:order => 'id')
#    assert_equal 2, conns.size
#    assert_properties conns[0], :page => @page, :page_version => 2, :connectable => @block, :connectable_version => 1, :container => "main"
#    assert_properties conns[1], :page => @page, :page_version => 3, :connectable => @block, :connectable_version => 2, :container => "main"
#  end

  test "Creation of connectors" do
    assert_equal 1, @block.connectors.all.size
    assert @block.update_attributes(:name => "something different")
    assert_equal 2, @block.connectors.all.size
  end
end