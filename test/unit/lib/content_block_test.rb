require File.join(File.dirname(__FILE__), '/../../test_helper')

class ContentBlockTest < ActiveSupport::TestCase
  def setup
    @block = Factory(:html_block, :name => "Test")   
  end
  
  def test_publishing
    assert_equal "Draft", @block.status_name
    assert !@block.published?

    @block.publish

    assert @block.published?

    @block.publish_on_save = true
    @block.save
    
    assert @block.published?

    assert @block.update_attributes(:name => "Whatever")
    
    assert !@block.live?
    
  end

  def test_revision_comment_on_create
    assert_equal 'Created', @block.draft.version_comment
  end

  def test_revision_comment_on_update
    assert @block.update_attributes(:name => "Something Else", :content => "Whatever")
    assert_equal 'Changed content, name', @block.draft.version_comment
  end

  def test_revision_comment_without_changes
    assert @block.update_attributes(:name => @block.name)
    assert_equal 'Created', @block.draft.version_comment
  end

  def test_custom_revision_comment
    assert @block.update_attributes(:name => "Something Else", :version_comment => "Something Changed")
    assert_equal "Something Changed", @block.draft.version_comment
  end
  
  def test_destroy
    html_block_count = HtmlBlock.count
    assert_equal 1, @block.versions.size
    assert !@block.deleted?
    
    @block.destroy

    assert !HtmlBlock.exists?(@block.id)
    assert !HtmlBlock.exists?(["name = ?", @block.name])
    assert_decremented html_block_count, HtmlBlock.count
    assert_raise(ActiveRecord::RecordNotFound) { HtmlBlock.find(@b) }
    assert_nil HtmlBlock.find_by_name(@block.name)

    deleted_block = HtmlBlock.find_with_deleted(@block.id)
    assert_equal 2, deleted_block.versions.size
    assert_equal 2, deleted_block.version
    assert_equal 1, deleted_block.versions.first.version
    assert_equal 2, HtmlBlock::Version.count(:conditions => {:html_block_id => @block.id})
  end  
  
  def test_delete_all
    HtmlBlock.delete_all(["name = ?", @block.name])
    assert_raise(ActiveRecord::RecordNotFound) { HtmlBlock.find(@block.id) }
    assert HtmlBlock.find_with_deleted(@block.id).deleted?
  end
  
end

class VersionedContentBlockConnectedToAPageTest < ActiveSupport::TestCase
  def setup
    @page = Factory(:page, :section => root_section)
    @block = Factory(:html_block, :name => "Versioned Content Block")
    @page.create_connector(@block, "main")
    reset(:page, :block)    
  end  
  
  def test_editing_connected_to_an_unpublished_page
    page_version_count = Page::Version.count
    assert !@page.published?
    
    assert @block.update_attributes(:name => "something different")
    reset(:page)
    
    assert !@page.published?
    assert_equal 3, @page.draft.version
    assert_incremented page_version_count, Page::Version.count
    assert_match /^HtmlBlock #\d+ was Edited/, @page.draft.version_comment

    conns = @block.connectors.all(:order => 'id')
    assert_equal 2, conns.size
    assert_properties conns[0], :page => @page, :page_version => 2, :connectable => @block, :connectable_version => 1, :container => "main"
    assert_properties conns[1], :page => @page, :page_version => 3, :connectable => @block, :connectable_version => 2, :container => "main"
  end
  
  def test_editing_connected_to_a_published_page
    @page.publish!
    reset(:page, :block)
    
    assert @page.published?
    assert @block.update_attributes(:name => "something different", :publish_on_save => true)
    reset(:page)
    
    assert @page.published?
  end  
  
  def test_deleting_when_connected_to_page
    @page.publish!
    reset(:page, :block)

    page_connector_count = @page.connectors.for_page_version(@page.draft.version).count
    page_version = @page.draft.version

    @block.destroy

    reset(:page)

    assert_decremented page_connector_count, @page.connectors.for_page_version(@page.draft.version).count
    assert_incremented page_version, @page.draft.version
    assert_match /^HtmlBlock #\d+ was Deleted/, @page.draft.version_comment
  end  
  
end

class NonVersionedContentBlockConnectedToAPageTest < ActiveSupport::TestCase
  def setup
    @page = Factory(:page, :section => root_section)
    @block = DynamicPortlet.create!(:name => "Non-Versioned Content Block")
    @page.create_connector(@block, "main")
    reset(:page, :block)    
  end

  def test_editing_connected_to_an_unpublished_page
    page_version_count = Page::Version.count

    assert_equal "Dynamic Portlet 'Non-Versioned Content Block' was added to the 'main' container",
      @page.draft.version_comment
    assert !@page.published?

    assert @block.update_attributes(:name => "something different", :publish_on_save => true)
    reset(:page)
    
    assert 2, @page.version
    assert_equal page_version_count, Page::Version.count
    assert !@page.published?
    
    conns = Connector.for_connectable(@block).all(:order => 'id')
    assert_equal 1, conns.size
    assert_properties conns[0], :page => @page, :page_version => 2, :connectable => @block, :connectable_version => nil, :container => "main"
  end
    
  def test_editing_connected_to_a_published_page
    @page.publish!
    reset(:page)
    
    assert @page.published?
    assert @block.update_attributes(:name => "something different", :publish_on_save => true)
    reset(:page)
    
    assert @page.published?
  end  
end