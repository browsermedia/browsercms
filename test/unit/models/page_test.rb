require File.join(File.dirname(__FILE__), '/../../test_helper')

class CreatingPageTest < ActiveRecord::TestCase
  
  def test_it
    
    @page = Page.new(
      :name => "Test", 
      :path => "test", 
      :section => root_section, 
      :publish_on_save => true)
    
    assert @page.save
    assert_path_is_unique
    
    @page.update_attributes(:name => "Test v2")
    
    page = Page.find_live_by_path("/test")
    assert_equal page.name, "Test"
    assert_equal 1, page.version
    
  end

  protected
    def assert_path_is_unique
      page = Factory.build(:page, :path => @page.path)
      assert_not_valid page
      assert_has_error_on page, :path
    end  
  
end

class PageTest < ActiveRecord::TestCase

  def test_creating_page_with_reserved_path
    @page = Page.new(:name => "FAIL", :path => "/cms")
    assert_not_valid @page
    assert_has_error_on(@page, :path, "is invalid, '/cms' a reserved path")
    
    @page = Page.new(:name => "FAIL", :path => "/cache")
    assert_not_valid @page
    assert_has_error_on(@page, :path, "is invalid, '/cache' a reserved path")
    
    @page = Page.new(:name => "FTW", :path => "/whatever")
    assert_valid @page
  end

  def test_find_live_by_path
    @page = Factory.build(:page, :path => '/foo')
    assert_nil Page.find_live_by_path('/foo')
    
    @page.publish!
    reset(:page)
    assert_equal @page, Page.find_live_by_path('/foo')
    
    @page.update_attributes(:path => '/bar')
    assert_equal @page, Page.find_live_by_path('/foo')
    assert_nil Page.find_live_by_path('/bar')
    
    @page.publish!
    reset(:page)
    assert_nil Page.find_live_by_path('/foo')
    assert_equal @page, Page.find_live_by_path('/bar')
  end

  def test_find_live_by_path_after_delete
    @page = Factory.build(:page, :path => '/foo')
    @page.publish!
    reset(:page)

    @page.mark_as_deleted!
    assert_nil Page.find_live_by_path('/foo')

    @new_page = Factory.build(:page, :path => '/foo')
    assert_nil Page.find_live_by_path('/foo')

    @new_page.publish!
    reset(:new_page)
    assert_equal @new_page, Page.find_live_by_path('/foo')
    assert_not_equal @page, @new_page
  end
  
  def test_path_normalization
    page = Factory.build(:page, :path => 'foo/bar')
    assert_valid page
    assert_equal "/foo/bar", page.path
    
    page = Factory.build(:page, :path => '/foo/bar')
    assert_valid page
    assert_equal "/foo/bar", page.path  
  end
  
  def test_template
    page_template = Factory(:page_template, :name => 'test')
    page = Factory.build(:page, :template_file_name => 'test.html.erb')
    assert_equal 'test.html.erb', page.template_file_name
    assert_equal 'Test (html/erb)', page.template_name
    assert_equal page_template, page.template
    assert_equal 'templates/test', page.layout
    
    page = Factory.build(:page, :template_file_name => 'foo.html.erb')
    assert_equal 'foo.html.erb', page.template_file_name
    assert_equal 'Foo (html/erb)', page.template_name
    assert_nil page.template
    assert_equal 'templates/foo', page.layout
  end
    
  def test_revision_comments
    page = Factory(:page, :section => root_section, :name => "V1")
    
    assert_equal 'Created', page.live_version.version_comment
    
    assert page.reload.save
    assert_equal 'Created', page.reload.live_version.version_comment
    assert_equal page.live_version.version_comment,
      page.as_of_version(page.version).live_version.version_comment

    page.update_attributes(:name => "V2")
    assert_equal 'Changed name', page.draft.version_comment
    assert_equal 'Created', page.live_version.version_comment

    block = Factory(:html_block, :name => "Hello, World!")
    page.create_connector(block, "main")
    assert_equal "Html Block 'Hello, World!' was added to the 'main' container",
      page.draft.version_comment
    assert_equal 'Created', page.live_version.version_comment
    assert_equal 3, page.reload.draft.version

    page.create_connector(Factory(:html_block, :name => "Whatever"), "main")
    assert_equal 4, page.reload.draft.version

    page.move_connector_down(page.connectors.for_page_version(page.reload.draft.version).for_connectable(block).first)
    assert_equal "Html Block 'Hello, World!' was moved down within the 'main' container",
      page.draft.version_comment
    assert_equal 'Created', page.live_version.version_comment

    page.move_connector_up(page.connectors.for_page_version(page.reload.draft.version).for_connectable(block).first)
    assert_equal "Html Block 'Hello, World!' was moved up within the 'main' container",
      page.draft.version_comment
    assert_equal 'Created', page.live_version.version_comment

    page.remove_connector(page.connectors.for_page_version(page.reload.draft.version).for_connectable(block).first)
    assert_equal "Html Block 'Hello, World!' was removed from the 'main' container",
      page.draft.version_comment
    assert_equal 'Created', page.live_version.version_comment

    page.revert_to(1)
    assert_equal "Reverted to version 1",
      page.reload.draft.version_comment
    assert_equal 'Created', page.live_version.version_comment

    assert_equal "Created", page.as_of_version(1).current_version.version_comment
    assert_equal "Changed name", page.as_of_version(2).current_version.version_comment
    assert_equal "Reverted to version 1", page.draft.version_comment

  end  
  
  def test_container_live
    page = Factory(:page)
    published = Factory(:html_block, :publish_on_save => true)
    unpublished = Factory(:html_block)
    page.create_connector(published, "main")
    page.create_connector(unpublished, "main")
    assert !page.container_published?("main")
    assert unpublished.publish
    assert page.container_published?("main")
  end
       
  def test_move_page_to_another_section
    page = Factory(:page, :section => root_section)
    section = Factory(:section, :name => "Another", :parent => root_section)
    assert_not_equal section, page.section
    page.section = section
    assert page.save
    assert_equal section, page.section
  end     

  def test_deleting_page
    page = Factory(:page)
    
    page_count = Page.count_with_deleted
    page_version_count = page.versions.count
    assert !page.deleted?
        
    page.destroy
    
    assert_equal page_count, Page.count_with_deleted
    assert_incremented page_version_count, page.versions.count
    assert page.deleted?
    assert_raise ActiveRecord::RecordNotFound do
      Page.find(page.id)
    end    
  end

  def test_adding_a_block_to_a_page_puts_page_in_draft_mode
    @page = Factory(:page, :section => root_section, :publish_on_save => true)
    @block = Factory(:html_block, :publish_on_save => true)
    reset(:page, :block)
    assert @page.published?
    assert @block.published?
    @page.create_connector(@block, "main")
    reset(:page, :block)
    assert !@page.live?
  end

  def test_reverting_and_then_publishing_a_page
    @page = Factory(:page, :section => root_section, :publish_on_save => true)
    
    @block = Factory(:html_block, 
      :connect_to_page_id => @page.id,
      :connect_to_container => "main")
    @page.publish
    
    reset(:page, :block)
    
    assert_equal 2, @page.version
    assert_equal 1, @page.connectors.for_page_version(@page.version).count
    
    @block.update_attributes(:content => "Something else")
    @page.publish!
    reset(:page, :block)
    
    assert_equal 1, @page.connectors.for_page_version(@page.version).count
    assert_equal 2, @block.version
    assert_equal 3, @page.version
    assert @block.live?
    assert @page.live?
    
    @page.revert_to(2)
    reset(:page, :block)

    assert_equal 3, @page.version
    assert_equal 4, @page.draft.version
    assert_equal 2, @block.version
    assert_equal 3, @block.draft.version    
    assert_equal 1, @page.connectors.for_page_version(@page.version).count
    assert_equal 1, @page.connectors.for_page_version(@page.draft.version).count    
    assert !@page.live?
    assert !@block.live?
      
  end

end

class PageVersioningTest < ActiveRecord::TestCase
  
  def setup
    @first_guy = Factory(:user, :login => "first_guy")
    @next_guy = Factory(:user, :login => "next_guy")
    User.current = @first_guy    
  end
  
  def teardown
    User.current = nil
  end
  
  def test_that_it_works
    page = Factory(:page, :name => "Original Value")
    
    assert_equal page, page.draft.page
    assert_equal @first_guy, page.updated_by
    
    User.current = @new_guy
    page.update_attributes(:name => "Something Different")

    assert_equal "Something Different", page.draft.name
    assert_equal "Original Value", page.reload.name
    assert_equal "Original Value", page.versions.first.name
    assert_equal @first_guy, page.versions.first.updated_by
    assert_equal @new_guy, page.versions.last.updated_by
    assert_equal 2, page.versions.count
  end
        
end

class PageInSectionTest < ActiveRecord::TestCase
  def test_that_it_returns_true_if_the_page_is_in_a_child_section_of_the_section
    @sports = Factory(:section, :parent => root_section, :name => "Sports")
    @nfl = Factory(:section, :parent => @sports, :name => "NFL")
    @mlb = Factory(:section, :parent => @sports, :name => "MLB")
    @afc = Factory(:section, :parent => @nfl, :name => "AFC")
    @al = Factory(:section, :parent => @mlb, :name => "AL")
    @afc_east = Factory(:section, :parent => @afc, :name => "AFC East")
    @al_east = Factory(:section, :parent => @al, :name => "AL East")
    @ravens = Factory(:section, :parent => @afc_east, :name => "Baltimore Ravens")
    @yanks = Factory(:section, :parent => @al_east, :name => "New York Yankees")
    @flacco = Factory(:page, :section => @ravens, :name => "Joe Flacco")
    @jeter = Factory(:page, :section => @yanks, :name => "Derek Jeter")

    [root_section, @sports].each do |s|
      assert @flacco.in_section?(s)
      assert @flacco.in_section?(s.name)
      assert @jeter.in_section?(s)
      assert @jeter.in_section?(s.name)
    end

    [@nfl, @afc, @afc_east, @ravens].each do |s|
      assert @flacco.in_section?(s)
      assert @flacco.in_section?(s.name)
      assert !@jeter.in_section?(s)
      assert !@jeter.in_section?(s.name)
    end

    [@mlb, @al, @al_east, @yanks].each do |s|
      assert !@flacco.in_section?(s)
      assert !@flacco.in_section?(s.name)
      assert @jeter.in_section?(s)
      assert @jeter.in_section?(s.name)
    end
  end
end

class PageWithAssociatedBlocksTest < ActiveRecord::TestCase
  def setup   
    super 
    @page = Factory(:page, :section => root_section, :name => "Bar")
    @block = Factory(:html_block)
    @other_connector = Factory(:connector, :connectable => @block, :connectable_version => @block.version)
    @page_connector = Factory(:connector, :page => @page, :page_version => @page.version, :connectable => @block, :connectable_version => @block.version)
  end
  
  # It should create a new page version and a new connector
  def test_updating_the_page_with_changes
    connector_count = Connector.count
    page_version = @page.version
    
    @page.update_attributes(:name => "Foo") 
    
    assert_incremented connector_count, Connector.count
    assert_equal page_version, @page.version
    assert_incremented page_version, @page.draft.version
  end
  
  # It should not create a new page version or a new connector
  def test_updating_the_page_without_changes  
    connector_count = Connector.count
    page_version = @page.version
    
    @page.update_attributes(:name => @page.name) 
    
    assert_equal connector_count, Connector.count
    assert_equal page_version, @page.version
  end

  def test_deleting_a_page
    connector_count = Connector.count
    assert Connector.exists?(@page_connector.id)
    assert Connector.exists?(@other_connector.id)
    
    @page.destroy
    
    assert_decremented connector_count, Connector.count
    assert !Connector.exists?(@page_connector.id)
    assert Connector.exists?(@other_connector.id)
    assert HtmlBlock.exists?(@block.id)
    assert !@block.deleted?
  end
end

class AddingBlocksToPageTest < ActiveRecord::TestCase
  def test_that_it_works
    @page = Factory(:page, :section => root_section)
    @block = Factory(:html_block)
    @block2 = Factory(:html_block) 
    @first_conn = @page.create_connector(@block, "testing")
    @second_conn = @page.create_connector(@block2, "testing")
    
    page_version_count = @page.versions.count
    connector_count = Connector.count
    
    @conn = @page.create_connector(@block2, "testing")

    assert_equal 1, @page.reload.version
    assert_equal 4, @conn.page_version
    assert_equal 1, @conn.connectable_version
    assert_incremented page_version_count, @page.versions.count
    assert_equal 3, @page.connectors.for_page_version(@page.draft.version).count
    assert_equal connector_count + 3, Connector.count
    
    # should leave the previous connectors untouched
    @conns = @page.connectors.all(:conditions => ["page_version < 4"], :order => "id")

    assert_equal 3, @conns.size

    assert_properties @conns[0], {
      :connectable => @block,
      :page => @page,
      :page_version => 2,
      :connectable_version => 1
    }
    
    assert_properties @conns[1], {
      :connectable => @block,
      :page => @page,
      :page_version => 3,
      :connectable_version => 1
    }
  
    assert_properties @conns[2], {
      :connectable => @block2,
      :page => @page,
      :page_version => 3,
      :connectable_version => 1          
    }

    @conns = @page.connectors.for_page_version(4).all(:order => "id")
    assert_equal 3, @conns.size
    
    assert_properties @conns[0], {
      :connectable => @block,
      :page => @page,
      :page_version => 4,
      :connectable_version => 1      
    }
    
    assert_properties @conns[1], {
      :connectable => @block2,
      :page => @page,
      :page_version => 4,
      :connectable_version => 1
    }
    
    assert_properties @conns[2], {
      :connectable => @block2,
      :page => @page,
      :page_version => 4,
      :connectable_version => 1 
    }
    
  end
end

class PageWithTwoBlocksTest < ActiveRecord::TestCase
  def setup
    super
    @page = Factory(:page, :section => root_section)
    @foo_block = Factory(:html_block, :name => "Foo Block")
    @bar_block = Factory(:html_block, :name => "Bar Block")
    @page.create_connector(@foo_block, "whatever")
    @page.reload
    @page.create_connector(@bar_block, "whatever")
    @page.reload
  end
  
  def test_editing_one_of_the_blocks_creates_a_new_version_of_the_page
    page_version = @page.draft.version
    @foo_block.update_attributes(:name => "Something Else")
    assert_incremented page_version, @page.draft.version
  end
  
  # A page that had 2 blocks added to it and then had them removed, 
  # when reverting to the previous version,
  # should restore the connectors from the version being reverted to
  def test_removing_and_reverting_to_previous_version
    remove_both_connectors!
    
    connector_count = Connector.count
    
    @page.revert
    
    assert_incremented connector_count, Connector.count
        
    assert_properties @page.reload.connectors.for_page_version(@page.draft.version).first, {
      :page => @page, 
      :page_version => 6, 
      :connectable => @bar_block, 
      :connectable_version => 1, 
      :container => "whatever"}
  end

  # A page that had 2 blocks added to it and then had then removed, 
  # when reverting to the version that had both connectors,
  # should restore the connectors that version
  def test_removing_and_reverting_to_version_with_both_connectors
    remove_both_connectors!
    
    connector_count = Connector.count
    
    @page.revert_to(3)
    
    assert_equal connector_count + 2, Connector.count
        
    foo, bar = @page.reload.connectors.for_page_version(@page.draft.version).find(:all, :order => "connectors.position")
    assert_properties foo, {
      :page => @page, 
      :page_version => 6, 
      :connectable => @foo_block, 
      :connectable_version => 1, 
      :container => "whatever"}
    assert_properties bar, {
      :page => @page, 
      :page_version => 6, 
      :connectable => @bar_block, 
      :connectable_version => 1, 
      :container => "whatever"}        
        
  end

  def test_updating_one_of_the_blocks_and_reverting_to_version_before_the_update
    target_version = @page.draft.version
    @foo_block.update_attributes!(:name => "Foo V2")
    @page.reload

    page_version = @page.draft.version
    foo_block_version = @foo_block.draft.version
    
    @page.revert_to(target_version)
    
    assert_incremented page_version, @page.draft.version
    assert_incremented foo_block_version, @foo_block.draft.version
    assert_equal "Foo Block", @page.connectors.for_page_version(@page.draft.version).reload.first.connectable.name
  end

  protected
    def remove_both_connectors!
      @page.remove_connector(@page.connectors.for_page_version(@page.draft.version).first(:order => "connectors.position"))
      @page.remove_connector(@page.connectors.for_page_version(@page.draft.version).first(:order => "connectors.position"))
    end

end

class PageWithBlockTest < ActiveRecord::TestCase
  def setup
    @page = Factory(:page, :section => root_section)
    @block = Factory(:html_block)
    @conn = @page.create_connector(@block, "bar") 
    @page.publish!
    @conn = @page.connectors.for_page_version(@page.version).for_connectable(@block).first
  end
  
  def test_removing_connector
    page_version = @page.draft.version
    page_version_count = Page::Version.count
    assert @page.published?
    
    @page.remove_connector(@conn)    
    
    assert_incremented page_version_count, Page::Version.count
    assert_incremented page_version, @page.draft.version
    
    conns = @page.connectors.for_page_version(@page.draft.version-1).all
    assert_equal 1, conns.size
    
    assert_properties conns.first, {
      :page => @page,
      :page_version => page_version,
      :connectable => @block,
      :connectable_version => @block.version
    }

    assert @page.reload.connectors.for_page_version(@page.draft.version).empty?
    assert !@page.live?
  end
  
  def test_removing_multiple_connectors
    @block2 = Factory(:html_block)
    @conn2 = @page.create_connector(@block2, "bar")
    @conn3 = @page.create_connector(@block2, "foo")
    #Need to get the new connector that matches @conn2, otherwise you will delete an older version, not the latest connector
    @conn2 = Connector.first(:conditions => {:page_id => @page.reload.id, :page_version => @page.draft.version, :connectable_id => @block2.id, :connectable_version => @block2.version, :container => "bar"})
    @page.remove_connector(@conn2)
    
    page_version_count = Page::Version.count
    page_version = @page.draft.version
    page_connector_count = @page.connectors.for_page_version(@page.draft.version).count
    
    @conn = Connector.first(:conditions => {:page_id => @page.reload.id, :page_version => @page.draft.version, :connectable_id => @block2.id, :connectable_version => @block2.version, :container => "foo"})
    @page.remove_connector(@conn) 
    @page.reload
    
    assert_incremented page_version_count, Page::Version.count
    assert_incremented page_version, @page.draft.version
    assert_decremented page_connector_count, 
      @page.connectors.for_page_version(@page.draft.version).count
      
    conns = @page.connectors.all(:order => "id")
    
    #log_array conns, :id, :page_id, :page_version, :connectable_id, :connectable_type, :connectable_version, :container, :position

    assert_equal 9, conns.size

    assert_properties conns[0], {:page => @page, :page_version => 2, :connectable => @block , :connectable_version => 1, :container => "bar", :position => 1}
    assert_properties conns[1], {:page => @page, :page_version => 3, :connectable => @block , :connectable_version => 1, :container => "bar", :position => 1}
    assert_properties conns[2], {:page => @page, :page_version => 3, :connectable => @block2, :connectable_version => 1, :container => "bar", :position => 2}
    assert_properties conns[3], {:page => @page, :page_version => 4, :connectable => @block , :connectable_version => 1, :container => "bar", :position => 1}
    assert_properties conns[4], {:page => @page, :page_version => 4, :connectable => @block2, :connectable_version => 1, :container => "bar", :position => 2}
    assert_properties conns[5], {:page => @page, :page_version => 4, :connectable => @block2, :connectable_version => 1, :container => "foo", :position => 1}
    assert_properties conns[6], {:page => @page, :page_version => 5, :connectable => @block , :connectable_version => 1, :container => "bar", :position => 1}
    assert_properties conns[7], {:page => @page, :page_version => 5, :connectable => @block2, :connectable_version => 1, :container => "foo", :position => 1}
    assert_properties conns[8], {:page => @page, :page_version => 6, :connectable => @block , :connectable_version => 1, :container => "bar", :position => 1}
  end
  
end

class UnpublishedPageWithOnePublishedAndOneUnpublishedBlockTest < ActiveRecord::TestCase
  def setup
    @page = Factory(:page, :section => root_section)
    @published_block = Factory(:html_block, :name => "Published")
    @unpublished_block = Factory(:html_block, :name => "Unpublished")
    @page.create_connector(@published_block, "main")
    @page.create_connector(@unpublished_block, "main")
    @published_block.publish!
    @page.reload    
  end
  
  def test_publishing_the_block
    @unpublished_block.publish!
    assert @unpublished_block.reload.published?
    @page.reload
    assert !@page.live?
  end
  
  def test_publishing_the_page
    page_version_count = Page::Version.count
    unpublished_block_version_count = @unpublished_block.versions.count
    published_block_version_count = @published_block.versions.count
    
    @page.publish!
    
    assert_equal page_version_count, Page::Version.count
    assert_equal unpublished_block_version_count, @unpublished_block.versions.count
    assert_equal published_block_version_count, @published_block.versions.count
    assert @page.live?
    assert @unpublished_block.reload.live?
    assert @published_block.reload.live?
  end
  
end

class RevertingABlockThatIsOnMultiplePagesTest < ActiveRecord::TestCase
  def test_that_it_reverts_both_pages
    
    # 1. Create a new page (Page 1, v1)    
    @page1 = Factory(:page, :name => "Page 1")
    assert_equal 1, @page1.version

    # 2. Create a new page (Page 2, v1)
    @page2 = Factory(:page, :name => "Page 2")

    # 3. Add a new html block to Page 1. Save, don't publish. (Page 1, v2)    
    @block = Factory(:html_block, :name => "Block v1", 
      :connect_to_page_id => @page1.id, :connect_to_container => "main")
    reset(:page1, :page2, :block)
    assert_equal 2, @page1.draft.version
    assert_equal 1, @page2.draft.version

    # 4. Goto page 2, and select that block. (Page 2, v2)    
    @page2.create_connector(@block, "main")
    reset(:page1, :page2, :block)
    assert_equal 2, @page1.draft.version
    assert_equal 2, @page2.draft.version

    # 5. Edit the block (Page 1, v3, Page 2, v3, Block v2)
    @block.update_attributes!(:name => "Block v2")
    reset(:page1, :page2, :block)
    assert_equal 3, @page1.draft.version
    assert_equal 3, @page2.draft.version
    assert_equal 2, @block.draft.version

    # 6. Revert page 1 to version 2. (Page 1, v4, Page 2, v4, Block v3)
    @page1.revert_to(2)
    reset(:page1, :page2, :block)
    assert_equal 4, @page1.draft.version
    assert_equal 3, @block.draft.version
    assert_equal 4, @page2.draft.version

    # Expected: Both page 1 and 2 will display the same version of the block (v1).
    assert_equal "Block v1", @page1.connectors.first.connectable.name
    assert_equal "Block v1", @page2.connectors.first.connectable.name
    
  end
    
end

class ViewingAPreviousVersionOfAPageTest < ActiveRecord::TestCase

  def test_that_it_shows_the_correct_version_of_the_blocks_it_is_connected_to
    # 1. Create Page A (v1)
    @page = Factory(:page, :section => root_section)
    
    # 2. Add new Html Block A to Page A (Page A v2, Block A v1)
    @block = Factory(:html_block, :name => "Block 1", :connect_to_page_id => @page.id, :connect_to_container => "main")
    reset(:page, :block)
    assert_equal 2, @page.draft.version
    assert_equal 1, @block.draft.version 
    
    # 3. Publish Page A (Page A v3, Block A v2)
    @page.publish!
    reset(:page, :block)
    assert_equal 2, @page.draft.version
    assert_equal 1, @block.draft.version 
    
    # 4. Edit Block A (Page A v4, Block A v3)
    @block.update_attributes!(:name => "Block 2")
    reset(:page, :block)
    assert_equal 2, @page.version
    assert_equal 3, @page.draft.version
    assert_equal 2, @block.draft.version 
     
    # Open Page A in a different browser (as guest)
    @live_page = Page.find_live_by_path(@page.path)
    assert_equal 2, @live_page.version
    assert_equal "Block 1", @live_page.connectors.for_page_version(@live_page.version).first.connectable.live_version.name
     
  end
end

class PortletsDontHaveDraftsTest < ActiveRecord::TestCase

  def test_connectors_with_portlets_should_correctly_be_copied
    @page = Factory(:page, :section=> root_section)
    @portlet = TagCloudPortlet.create(:name=>"Portlet", :connect_to_page_id => @page.id, :connect_to_container => "main")

    # Check some assumptions.
    assert_equal 2, @page.draft.version, "Verifying that adding a portlet correctly increments page version."
    connectors = Connector.for_connectable(@portlet)
    assert_equal 1, connectors.size, "This portlet should have only 1 connector."

    # Verifies that an exception is not thrown while removing connectors
    @page.remove_connector(connectors[0])

    assert_equal 3, @page.draft.version
    assert @page.reload.connectors.for_page_version(@page.draft.version).empty?, "Verify that all connectors for the latest page are removed."
  end
end

