require 'test_helper'

class ContentBlockTest < ActiveSupport::TestCase
  def setup
    @block = create(:html_block, :name => "Test")
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

  test "Updating a block without changing attributes shouldn't cause new save" do
    result = @block.update_attributes(:name => @block.name)
    assert_equal 1, @block.version, "Block should keep itself at version 1"
    assert_equal 1, @block.versions.size, "Should only have the one original version of the block"
    assert_equal 'Created', @block.draft.version_comment
    assert result , "Update with same attributes should still return true" 
  end

  def test_custom_revision_comment
    assert @block.update_attributes(:name => "Something Else", :version_comment => "Something Changed")
    assert_equal "Something Changed", @block.draft.version_comment
  end

  
end

class SoftPublishingTest < ActiveSupport::TestCase

  def setup
    @block = create(:html_block, :name => "Test")
  end

  test "deleted? should return true for deleted records, false otherwise" do
    assert_equal false, @block.deleted?
    @block.destroy  
    assert_equal true, @block.deleted?
  end

  test "Destroying a block should mark it as deleted, rather than remove it from the database" do
    @block.destroy

    found = Cms::HtmlBlock.find_by_sql("SELECT * FROM #{Cms::HtmlBlock.table_name} where id = #{@block.id}")
    assert_equal 1, found.size, "Should find one record"
    assert_not_nil found[0], "A block should still exist in the database"
    assert_equal true, found[0].deleted, "It's published flag should be true"

  end

  test "exists? should not return blocks marked as deleted" do
    @block.destroy

    assert_equal false, Cms::HtmlBlock.exists?(@block.id)
    assert_equal false, Cms::HtmlBlock.exists?(["name = ?", @block.name])
  end

  test "find by id should throw an exception for records marked as deleted" do
    @block.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Cms::HtmlBlock.find(@b) }

  end

  test "dynamic finders (i.e. find_by_name) should not find deleted records" do
    @block.destroy
    assert_nil Cms::HtmlBlock.find_by_name(@block.name)
  end


  test "find with deleted returns all records even marked as deleted" do
    @block.destroy
    assert_not_nil Cms::HtmlBlock.find_with_deleted(@block.id)
  end

  test "Marking as deleted should create a new record in the versions table" do
    @block.destroy


    deleted_block = Cms::HtmlBlock.find_with_deleted(@block.id)
    assert_equal 2, deleted_block.versions.size
    assert_equal 2, deleted_block.version
    assert_equal 1, deleted_block.versions.first.version
    assert_equal 2, Cms::HtmlBlock::Version.count(:conditions => {:original_record_id => @block.id})
  end

  test "Count should exclude deleted records" do
    html_block_count = Cms::HtmlBlock.count
    @block.destroy
    assert_decremented html_block_count, Cms::HtmlBlock.count

  end

  test "count_with_deleted should return all records, even those marked as deleted" do
    original_count = Cms::HtmlBlock.count
    @block.destroy
    assert_equal original_count, Cms::HtmlBlock.count_with_deleted
  end


  def test_delete_all
    Cms::HtmlBlock.delete_all(["name = ?", @block.name])
    assert_raise(ActiveRecord::RecordNotFound) { Cms::HtmlBlock.find(@block.id) }
    assert Cms::HtmlBlock.find_with_deleted(@block.id).deleted?
  end
end

class VersionedContentBlockTest < ActiveSupport::TestCase
  def setup
    @block = create(:html_block, :name => "Versioned Content Block")
  end

  test "Calling publish! on a block should save it, and mark that block as published." do
    @block.publish!

    found = Cms::HtmlBlock.find(@block)
    assert_equal true, found.published?
  end

  test "Getting a block as of a particular version shouldn't be considered a 'new record'." do
    @block.update_attributes(:name=>"Changed", :publish_on_save=>true)
    @block.reload

    @v1 = @block.as_of_version(1)
    assert_equal false, @v1.new_record?, "Old versions of blocks aren't 'new' and shouldn't ever be resaved."

  end

  test 'Calling publish_on_save should not be sufficent to publish the block'do
    @block.publish_on_save = true
    @block.save

    found = Cms::HtmlBlock.find(@block)
    assert_equal 1, found.version 
  end

  test "Setting the 'publish' flag on a block, along with any other change, and saving it should mark that block as published." do
    @block.publish_on_save = true
    @block.name = "Anything else"
    @block.save

    found = Cms::HtmlBlock.find(@block)
    assert_equal true, found.published?
  end

  def test_edit
    old_name = "Versioned Content Block"
    new_name  = "New version of content block"
    @block.publish!
    @block.reload
    assert_equal @block.draft.name, old_name
    @block.name = new_name
    @block.save
    @block.reload
    assert_equal @block.draft.name, new_name
    @block.name = old_name
    @block.save
    @block.reload
    assert_equal @block.draft.name, old_name
  end

  def test_revert
    old_name = "Versioned Content Block"
    new_name  = "New version of content block"
    @block.publish!
    @block.reload
    assert_equal @block.draft.name, old_name
    version = @block.version
    @block.name = new_name
    @block.save
    @block.reload
    assert_equal @block.draft.name, new_name
    @block.revert_to(version)
    @block.reload
    assert_equal @block.draft.name, old_name
  end

end

class VersionedContentBlockConnectedToAPageTest < ActiveSupport::TestCase
  def setup
    @page = create(:page, :section => root_section)
    @block = create(:html_block, :name => "Versioned Content Block")
    @page.create_connector(@block, "main")
    reset(:page, :block)
  end

  def test_editing_connected_to_an_unpublished_page
    page_version_count = Cms::Page::Version.count
    assert_equal 2, @page.versions.size, "Should be two versions of the page"
    assert !@page.published?, "The page should not be published yet."

    pages = Cms::Page.connected_to(:connectable => @block, :version => @block.version).all
    assert_equal [@page], pages, "The block should be connected to page"


    assert @block.update_attributes(:name => "something different")
    assert_equal false, @block.skip_callbacks
    assert_equal 2, @block.versions.size, "should be two versions of this block"
    reset(:page)


    assert !@page.published?
    assert_equal 3, @page.versions.size, "Should be three versions of the page."
    assert_equal 3, @page.draft.version, "Draft version of page should be updated to v3 since its connected to the updated block."
    assert_incremented page_version_count, Cms::Page::Version.count
    assert_match /^HtmlBlock #\d+ was Edited/, @page.draft.version_comment

    conns = @block.connectors.all(:order => 'id')
    assert_equal 2, conns.size
    assert_properties conns[0], :page => @page, :page_version => 2, :connectable => @block, :connectable_version => 1, :container => "main"
    assert_properties conns[1], :page => @page, :page_version => 3, :connectable => @block, :connectable_version => 2, :container => "main"
  end

  # Verify that when we have a block connected to a published page, the page should remain published.
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
    @page = create(:page, :section => root_section)
    @block = create(:non_versioned_block, :name => "Non-Versioned Non-Publishable Content Block")
    @page.create_connector(@block, "main")
    reset(:page, :block)
  end

  def test_editing_connected_to_an_unpublished_page
    page_version_count = Cms::Page::Version.count

    assert_equal "Dynamic Portlet '#{@block.name}' was added to the 'main' container", @page.draft.version_comment
    assert !@page.published?

    assert @block.update_attributes(:name => "something different")
    reset(:page)

    assert 2, @page.version
    assert_equal page_version_count, Cms::Page::Version.count
    assert !@page.published?

    conns = Cms::Connector.for_connectable(@block).all(:order => 'id')
    assert_equal 1, conns.size
    assert_properties conns[0], :page => @page, :page_version => 2, :connectable => @block, :connectable_version => nil, :container => "main"
  end


  def test_editing_connected_to_a_published_page
    @page.publish!
    reset(:page)

    assert @page.published?
    assert @block.update_attributes(:name => "something different")
    reset(:page)

    assert @page.published?
  end
end
