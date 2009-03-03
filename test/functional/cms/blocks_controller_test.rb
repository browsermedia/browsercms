require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::BlocksControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
    @block = Factory(:html_block, :name => "Test", :content => "I worked.")
  end
  
  def test_add_new_html_block
    get :new, :block_type => "html_blocks"
    assert_response :success    
    assert_select "h1", "Add New Text"
  end

  def test_add_new_image_block
    get :new, :block_type => "image_blocks"
    assert_response :success    
    assert_select "h1", "Add New Image"
  end
  
  def test_add_new_block_to_a_page
    @page = Factory(:page, :path => "/test", :section => root_section)
    get :new, :html_block => {:connect_to_page_id => @page.id, :connect_to_container => "test"}
    assert_response :success
    assert_select "input[name=?][value=?]", "html_block[connect_to_page_id]", @page.id.to_s
    assert_select "input[name=?][value=?]", "html_block[connect_to_container]", "test"
  end
  
  def test_showing_a_block
    get :show, :id => @block.id

    assert_response :success
    assert_select "div.content", "I worked."
    assert_select "a", "List Versions"
  end
  
  def test_creating_a_block_that_should_be_connected_to_a_page
    @page = Factory(:page, :path => "/test", :section => root_section)
    html_block_count = HtmlBlock.count

    post :create, :html_block => Factory.attributes_for(:html_block).merge(
      :connect_to_page_id => @page.id, :connect_to_container => "test")
      
    assert_incremented html_block_count, HtmlBlock.count
    assert_equal "test", @page.reload.connectors.first.container
    assert_redirected_to @page.path
  end  
  
  def test_list_blocks
    get :index
    assert_response :success
    assert_select "td", "Test"
    assert_select "td.block_status"  do
      assert_select "img[alt=?]", "Draft"
    end
  end
  
  def test_list_nonsearchable_blocks
    get :index, :block_type => "portlet"
    assert_response :success
  end  
  
  def test_html_block_search
    get :index, :search => {:term => 'test'}
    assert_response :success
    assert_select "td", "Test"

    get :index, :search => {:term => 'worked', :include_body => true }
    assert_response :success
    assert_select "td", "Test"

    get :index, :search => {:term => 'invalid'}
    assert_response :success
    assert_select "td", {:count=>0, :text=>"Test"}
  end

  def test_file_block_search
    @file = mock_file(:read => "This is a test")
    @file_block = Factory(:file_block, :attachment_section => root_section, 
      :attachment_file => @file, 
      :attachment_file_path => "/test.txt", 
      :name => "Test File", 
      :publish_on_save => true)
    @foo_section = Factory(:section, :name => "Foo", :parent => root_section)

    get :index, :block_type => 'file_block', :section_id => root_section.id
    assert_response :success
    assert_select "td", "Test File"

    get :index, :block_type => 'file_block', :section_id => @foo_section.id
    assert_response :success
    assert_select "td", {:count => 0, :text => "Test File"}

    get :index, :block_type => 'file_block', :section_id => 'all'
    assert_response :success
    assert_select "td", "Test File"
  end
  
  def test_edit_block
    get :edit, :id => @block.id
    assert_response :success
    assert_select "input[id=?][value=?]", "html_block_name", "Test"
  end  
  
  def test_edit_image_block
    @image = Factory(:image_block, 
      :attachment_section => root_section, 
      :attachment_file => mock_file, 
      :attachment_file_path => "test.jpg")
      
    get :edit, :block_type => "image_blocks", :id => @image.id
    
    assert_response :success
    assert_equal root_section.id, assigns(:block).attachment_section_id
    assert_select "h1", "Edit Image '#{@image.name}'"
    assert_select "select[name=?]", "image_block[attachment_section_id]" do
      assert_select "option[value=?][selected=?]", root_section.id, "selected"
    end
  end
  
  def test_update_block
    html_block_count = HtmlBlock.count
    html_block_version_count = HtmlBlock::Version.count
    
    put :update, :id => @block.id, :html_block => {:name => "Test V2"}
    reset(:block)

    assert_redirected_to cms_url(@block)
    assert_equal html_block_count, HtmlBlock.count
    assert_incremented html_block_version_count, HtmlBlock::Version.count
    assert_equal "Test V2",  @block.name
    assert_equal "Html Block 'Test V2' was updated", flash[:notice]
  end
  
  def test_update_image_block
    @image = Factory(:image_block, 
      :attachment_section => root_section, 
      :attachment_file => mock_file, 
      :attachment_file_path => "test.jpg")
    @other_section = Factory(:section, :parent => root_section, :name => "Other")
    
    put :update, :block_type => "image_blocks", :id => @image.id, :image_block => {:attachment_section_id => @other_section.id}
    reset(:image)

    assert_redirected_to cms_url(@image)
    assert_equal @other_section, @image.attachment_section
  end
  
  def test_publish
    assert !@block.published?

    post :publish, :id => @block.id
    reset(:block)

    assert_redirected_to cms_url(@block)
    assert @block.published?
  end  
  
  def test_list_revisions
    get :revisions, :id => @block.id
    assert_response :success
    assert_equal @block, assigns(:block)
  end  
  
  def test_revert_to
    @block.update_attributes(:name => "Test V2")
    reset(:block)
    
    post :revert_to, :id => @block.id, :version => "1"
    reset(:block)
    
    assert_equal 3, @block.version
    assert_equal "Test", @block.reload.name
    assert_equal "Reverted 'Test' to version 1", flash[:notice]
    assert_redirected_to cms_url(@block)
  end
  
  def test_revert_to_without_version_parameter
    @block.update_attributes(:name => "Test V2")
    reset(:block)

    html_block_version_count = HtmlBlock::Version.count
    
    post :revert_to, :id => @block.id
    reset(:block)
    
    assert_equal html_block_version_count, HtmlBlock::Version.count
    assert_equal "Could not revert 'Test V2': Version parameter missing", flash[:error]
    assert_redirected_to cms_url(@block)
  end

  def test_revert_to_with_invalid_version_parameter
    @block.update_attributes(:name => "Test V2")
    reset(:block)

    html_block_version_count = HtmlBlock::Version.count
    
    post :revert_to, :id => @block.id, :version => 99
    reset(:block)
    
    assert_equal html_block_version_count, HtmlBlock::Version.count
    assert_equal "Could not revert 'Test V2': Could not find version 99", flash[:error]
    assert_redirected_to cms_url(@block)
  end
  
  def test_routing_based_on_block_type
    assert_routing '/cms/blocks/html_block/show/1', {
      :controller => 'cms/blocks', :action=>'show', :id => '1', :block_type=>'html_block'}
  end
end

class Cms::BlocksControllerForPortletTest < ActionController::TestCase
  tests Cms::BlocksController
  include Cms::ControllerTestHelper
    
  def setup
    login_as_cms_admin
    @block = DynamicPortlet.create(:name => "V1", :code => "@foo = 42", :template => "<%= @foo %>")    
  end
    
  def test_show
    get :show, :id => @block.id, :block_type => "portlets"
    assert_response :success
    assert_select "a#revisions_link", false
  end
  
  def test_revisions
    get :revisions, :id => @block.id, :block_type => "portlets"
    assert_response :not_implemented
  end
  
  def test_new
    get :new, :block_type => "portlets"
    assert_response :success
    assert_select "title", "Content Library / Select Portlet Type"
  end
  
  def test_edit
    get :edit, :id => @block.id, :block_type => "DynamicPortlet"
    assert_response :success
    assert_select "h1", "Edit Dynamic Portlet 'V1'"
  end  
  
  def test_destroy
    delete :destroy, :id => @block.id, :block_type => "DynamicPortlet"
    assert_redirected_to cms_path(:content_library)
    assert_raise(ActiveRecord::RecordNotFound) { DynamicPortlet.find(@block.id) }
  end
  
end