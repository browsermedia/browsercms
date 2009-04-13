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
  
end