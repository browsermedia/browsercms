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
  
  def test_versioning
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

class DeletingPageTest < ActiveSupport::TestCase
  #TODO
end