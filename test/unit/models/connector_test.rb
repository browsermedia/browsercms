require File.join(File.dirname(__FILE__), '/../../test_helper')

class ConnectorTest < ActiveSupport::TestCase
  
  def test_container_is_required
    connector = Factory.build(:connector, :container => nil)
    assert_not_valid connector
    assert_has_error_on connector, :container
  end
  
  def test_find_by_block
    foo = Factory(:html_block, :name => "foo")
    bar = Factory(:html_block, :name => "bar")
    Factory(:connector, :connectable => foo, :connectable_version => foo.version)
    blocks = Connector.for_connectable(foo).map(&:connectable)
    assert blocks.include?(foo)
    assert !blocks.include?(bar)
  end
  
  def test_only_find_connectors_for_a_block_that_match_the_current_version
    @foo = Factory(:html_block, :name => "foo")
    @foo.update_attribute(:name, "foo v2")
    @bar = Factory(:html_block, :name => "bar")
    @con = Factory(:connector, :connectable => @foo)
    @con.update_attribute(:connectable_version, 99)
    reset(:con)
    assert_raise(ActiveRecord::RecordNotFound) { @con.current_connectable }
  end
  
  def test_only_find_connectors_for_the_current_version_of_the_page
    @page = Factory(:page, :section => root_section)
    @connector = Factory(:connector, :page => @page)
    @page.update_attributes(:name => "Updated")
    assert_equal 1, @page.reload.connectors.for_page_version(@page.version).count
  end
  
  def test_blocks_not_deleted_when_connector_is_not_deleted
    b = Factory(:html_block)
    c = Factory(:connector, :connectable => b)
    connector_count = Connector.count
    c.destroy
    assert_decremented connector_count, Connector.count
    assert !HtmlBlock.find_by_id(b.id).nil?
  end
  
  def test_re_order_blocks_within_a_container
    page = Factory(:page)
    one = Factory(:connector, :page => page, :container => "foo")
    two = Factory(:connector, :page => page, :container => "foo")
    three = Factory(:connector, :page => page, :container => "foo")
    
    two.reload.move_up
    assert_equal [two, one, three].map(&:id),
      page.reload.connectors.for_page_version(page.version).in_container("foo").all.map(&:id)
    
    two.reload.move_down
    assert_equal [one, two, three],
      page.reload.connectors.for_page_version(page.version).in_container("foo").all
    
    three.reload.move_to_top
    assert_equal [three, one, two],
      page.reload.connectors.for_page_version(page.version).in_container("foo").all
    
    one.reload.move_to_bottom
    assert_equal [three, two, one],
      page.reload.connectors.for_page_version(page.version).in_container("foo").all
  end
  
  def test_connectable_with_deleted
    @page = Factory(:page)
    @block = Factory(:html_block, :name => "Deleted", 
      :connect_to_page_id => @page.id,
      :connect_to_container => "main",
      :publish_on_save => "true")
    
    reset(:page, :block)
    @block.destroy
    
    reset(:page)

    log_table_without_stamps Connector
    
    assert_nil @page.connectors.for_page_version(2).first.connectable
    
    c = @page.connectors.for_page_version(2).first.connectable_with_deleted
    assert !c.nil?
    assert_equal @block.id, c.id
    assert_equal @block.name, c.name
    assert_equal 1, c.version
  end

  def test_connector_should_be_copied_when_it_has_a_connectable
    @page = Factory(:page)
    @block = Factory(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "main")

    conn = Connector.new
    conn.connectable = @block
    assert(conn.connectable, "Check the assumption there is connectable.")
    assert_equal(false, conn.connectable.draft.deleted?, "Check the assumption that the draft is not-deleted.")

    assert(conn.should_be_copied?, "Verifes that normally a connector should be copied.")
  end

  def test_connector_shouldnt_copy_when_its_connectable_is_nil
    conn = Connector.new
    assert_nil(conn.connectable, "Check assumption that connectable is nil.")

    assert_equal false, conn.should_be_copied?, "Shouldn't copy when a connector isn't connected to anything."
  end

  def test_connector_should_copy_when_its_latest_draft_is_deleted
    @page = Factory(:page)
    @block = Factory(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "main")

    @block.destroy

    conn = Connector.new
    conn.connectable = @block

    assert_equal true, @block.draft.deleted?, "Check assumption that latest draft of this block is 'deleted'."
    assert_equal false, conn.should_be_copied?, "Should not copy when latest draft is deleted."

  end

  def test_connector_should_copy_even_if_connectable_doesnt_have_drafts
    @page = Factory(:page)
    @block = Portlet.create!(:name => "Stuff")

    conn = Connector.new
    conn.connectable = @block

    assert_equal false, @block.respond_to?(:draft), "Check assumption that portlets do not respond to draft method."
    assert_equal true, conn.should_be_copied?, "Should not copy when latest draft is deleted."

  end
  
  def test_connector_with_file_block_status
    @page = Factory(:page)
    @file = Factory(:image_block, :connect_to_page_id => @page.id, :connect_to_container => "main", :publish_on_save => true)
    @page.reload
    
    assert @file.live?
    assert @page.connectors.last.live?
    
    @file.update_attributes(:name => "Something Else")
    @page.reload

    assert !@file.live?
    assert !@page.connectors.last.live?    
  end  
  
end