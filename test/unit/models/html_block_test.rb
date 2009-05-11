require File.join(File.dirname(__FILE__), '/../../test_helper')

class HtmlBlockTest < ActiveSupport::TestCase
  def test_create    
    @page = Factory(:page)
    @html_block = Factory(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "test")
    assert_equal 1, @page.reload.connectors.count
    assert_equal @page, @html_block.connected_page
    assert_equal @page.id, @html_block.connect_to_page_id
    assert_equal "test", @html_block.connect_to_container
  end
  
  def test_versioning
    assert HtmlBlock.versioned?
    
    @html_block = Factory(:html_block, :name => "Original Value")
    assert_equal @html_block, @html_block.versions.last.html_block

    # Updates should make a new version
    assert @html_block.update_attributes(:name => "Something Different")
    assert_equal @html_block, @html_block.versions.last.html_block
    assert_equal "Something Different", @html_block.versions.last.name
    assert_equal "Something Different", @html_block.name
    assert_equal "Original Value", @html_block.versions.first.name
  
    # Updating with no changes should not generate a new version
    html_block_version_count = @html_block.versions.count
    @html_block.update_attributes(:name => "Something Different")
    assert_equal html_block_version_count, @html_block.versions.count
    
    # deleting should create a new version
    html_block_count = HtmlBlock.count_with_deleted
    html_block_version_count = @html_block.versions.count
    assert !@html_block.deleted?
    
    @html_block.destroy    
    
    assert_equal html_block_count, HtmlBlock.count_with_deleted
    assert_incremented html_block_version_count, @html_block.versions.count
    assert @html_block.deleted?
    
  end
  
  def test_reverting
    # We need a block with a version that was created in the past
    @v1_created_at = Time.zone.now - 5.days
    @html_block = Factory(:html_block, :name => "Version One", :created_at => @v1_created_at)
    
    # Make the version be created in the past as well
    v1 = @html_block.versions.last
    v1.created_at = @v1_created_at
    v1.save

    # Make a new version
    @html_block.update_attributes(:name => "Version Two")
    @v2_created_at = @html_block.versions.last.created_at

    assert_equal "Version Two", @html_block.name
    assert_equal @v1_created_at.to_i, @html_block.find_version(1).created_at.to_i
    assert_equal @v2_created_at.to_i, @html_block.find_version(2).created_at.to_i
    
    @html_block.revert_to 1
    @html_block.reload

    assert_equal 3, @html_block.draft.version
    assert_equal "Version One", @html_block.name
    assert_equal @v1_created_at.to_i, @html_block.find_version(1).created_at.to_i
    assert_equal @v2_created_at.to_i, @html_block.find_version(2).created_at.to_i
    assert @html_block.find_version(3).created_at.to_i >= @v2_created_at.to_i
    assert @v1_created_at.to_i, @html_block.created_at.to_i
    
    # version is required for revert_to
    html_block_version_count = HtmlBlock::Version.count
    assert_raise "Version parameter missing" do
      @html_block.revert_to nil
    end
    assert_equal html_block_version_count, HtmlBlock::Version.count
     
    html_block_version_count = HtmlBlock::Version.count
    assert_raise "Could not find version 42" do
      @html_block.revert_to 42
    end
    assert_equal html_block_version_count, HtmlBlock::Version.count 
  end
  
  def test_previous_version
    @html_block = Factory(:html_block, :name => "V1")
    @html_block.update_attributes(:name => "V2")
    @version = @html_block.as_of_version 1
    
    assert_equal HtmlBlock, @version.class
    assert_equal "V1", @version.name
    assert_equal 1, @version.version
    assert_equal @html_block.id, @version.id
    
    # We can't freeze the version because we need to be able to load assocations
    assert !@version.frozen?
    assert !@version.live?
    assert !@html_block.live?
  end
  
end