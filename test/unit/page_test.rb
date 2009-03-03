require File.join(File.dirname(__FILE__), '/../test_helper')

class CreatingPageTest < ActiveSupport::TestCase
  
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

class PageTest < ActiveSupport::TestCase
  def test_path_normalization
    page = Factory.build(:page, :path => 'foo/bar')
    assert_valid page
    assert_equal "/foo/bar", page.path
    
    page = Factory.build(:page, :path => '/foo/bar')
    assert_valid page
    assert_equal "/foo/bar", page.path  
  end
    
  def test_revision_comments
    page = Factory(:page, :section => root_section, :name => "V1")
    
    assert_equal 'Created', page.current_version.version_comment
    
    assert page.reload.save
    assert_equal 'Created', page.reload.current_version.version_comment
    assert_equal page.current_version.version_comment,
      page.as_of_version(page.version).current_version.version_comment

    page.update_attributes(:name => "V2")
    assert_equal 'Changed name', page.current_version.version_comment
    assert_equal page.current_version.version_comment,
      page.as_of_version(page.version).current_version.version_comment

    block = Factory(:html_block, :name => "Hello, World!")
    page.create_connector(block, "main")
    assert_equal "Html Block 'Hello, World!' was added to the 'main' container",
      page.current_version.version_comment
    assert_equal page.current_version.version_comment,
      page.as_of_version(page.version).current_version.version_comment

    page.create_connector(Factory(:html_block, :name => "Whatever"), "main")

    page.move_connector_down(page.connectors.for_page_version(page.version).for_connectable(block).first)
    assert_equal "Html Block 'Hello, World!' was moved down within the 'main' container",
      page.current_version.version_comment
    assert_equal page.current_version.version_comment,
      page.as_of_version(page.version).current_version.version_comment

    page.move_connector_up(page.connectors.for_page_version(page.version).for_connectable(block).first)
    assert_equal "Html Block 'Hello, World!' was moved up within the 'main' container",
      page.current_version.version_comment
    assert_equal page.current_version.version_comment,
      page.as_of_version(page.version).current_version.version_comment

    page.remove_connector(page.connectors.for_page_version(page.version).for_connectable(block).first)
    assert_equal "Html Block 'Hello, World!' was removed from the 'main' container",
      page.current_version.version_comment
    assert_equal page.current_version.version_comment,
      page.as_of_version(page.version).current_version.version_comment

    page.revert_to(1)
    assert_equal "Reverted to version 1",
      page.reload.current_version.version_comment
    assert_equal page.current_version.version_comment,
      page.as_of_version(page.version).current_version.version_comment

    assert_equal "Created", page.as_of_version(1).current_version.version_comment
    assert_equal "Changed name", page.as_of_version(2).current_version.version_comment
    assert_equal "Reverted to version 1", page.current_version.version_comment

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
    assert_equal page_version_count + 1, page.versions.count
    assert page.deleted?
    assert_raise ActiveRecord::RecordNotFound do
      Page.find(page.id)
    end    
  end

end

class PageVersioningTest < ActiveSupport::TestCase
  
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
    
    assert_equal page, page.current_version.page
    assert_equal @first_guy, page.updated_by
    
    User.current = @new_guy
    page.update_attributes(:name => "Something Different")

    assert_equal page, page.current_version.page
    assert_equal "Something Different", page.current_version.name
    assert_equal "Something Different", page.name
    assert_equal "Original Value", page.versions.first.name
    assert_equal @first_guy, page.versions.first.updated_by
    assert_equal @new_guy, page.versions.last.updated_by

    assert_equal 2, page.versions.count
    page.update_attributes(:name => "Something Different")
    assert_equal 2, page.versions.count
  end
        
end

class PageInSectionTest < ActiveSupport::TestCase
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

class PageWithAssociatedBlocksTest < ActiveSupport::TestCase
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
    
    assert_equal connector_count + 1, Connector.count
    assert_equal page_version + 1, @page.version
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
    
    assert_equal connector_count - 1, Connector.count
    assert !Connector.exists?(@page_connector.id)
    assert Connector.exists?(@other_connector.id)
    assert HtmlBlock.exists?(@block.id)
    assert !@block.deleted?
  end
end

class AddingBlocksToPageTest < ActiveSupport::TestCase
  def test_that_it_works
    @page = Factory(:page, :section => root_section)
    @block = Factory(:html_block)
    @block2 = Factory(:html_block) 
    @first_conn = @page.create_connector(@block, "testing")
    @second_conn = @page.create_connector(@block2, "testing")
    
    page_version = @page.version
    connector_count = Connector.count
    
    @conn = @page.create_connector(@block2, "testing")

    assert_equal 4, @page.reload.version
    assert_equal 4, @conn.page_version
    assert_equal 1, @conn.connectable_version
    assert_equal page_version + 1, @page.version 
    assert_equal 3, @page.connectors.for_page_version(@page.version).count
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

class PageWithTwoBlocksTest < ActiveSupport::TestCase
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
  
  # A page that had 2 blocks added to it and then had them removed, 
  # when reverting to the previous version,
  # should restore the connectors from the version being reverted to
  def test_removing_and_reverting_to_previous_version
    remove_both_connectors!
    
    connector_count = Connector.count
    
    @page.revert 
    
    assert_equal connector_count + 1, Connector.count
        
    assert_properties @page.reload.connectors.for_page_version(@page.version).first, {
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
        
    foo, bar = @page.reload.connectors.for_page_version(@page.version).find(:all, :order => "connectors.position")
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
    @foo_block.update_attributes!(:name => "Foo V2")
    @page.reload

    page_version = @page.version
    foo_block_version = @foo_block.version
    
    @page.revert_to(3)
    
    assert_equal page_version + 1, @page.version
    assert_equal foo_block_version + 1, @foo_block.reload.version
    assert_equal "Foo Block", @page.connectors.for_page_version(@page.version).reload.first.connectable.name
  end

  protected
    def remove_both_connectors!
      @page.remove_connector(@page.reload.connectors.for_page_version(@page.version).first(:order => "connectors.position"))
      @page.remove_connector(@page.reload.connectors.for_page_version(@page.version).first(:order => "connectors.position"))      
    end

end

