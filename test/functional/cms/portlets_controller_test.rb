require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::PortletsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
    
  def setup
    login_as_cms_admin
    @block = DynamicPortlet.create!(:name => "V1", :code => "@foo = 42", :template => "<%= @foo %>")    
  end
  
  def test_index
    get :index
    assert_response :success
    assert_select "#dynamic_portlet_#{@block.id}"
  end
  
  def test_index_does_not_show_deleted_portlets
    @block.destroy
    get :index
    assert_response :success
    assert_select "#dynamic_portlet_#{@block.id}", 0
  end
    
  def test_show
    get :show, :id => @block.id
    assert_response :success
    assert_select "a#revisions_link", false
  end
  
  def test_new
    get :new
    assert_response :success
    assert_select "title", "Content Library / Select Portlet Type"
  end
  
  def test_edit
    get :edit, :id => @block.id
    assert_response :success
    assert_select "title", "Content Library / Edit Portlet"
    assert_select "h1", "Edit Portlet 'V1'"
  end  
  
  def test_destroy
    delete :destroy, :id => @block.id
    assert_redirected_to cms_portlets_path
    assert_raise(ActiveRecord::RecordNotFound) { DynamicPortlet.find(@block.id) }
  end

  def test_usages
    @page = Factory(:page, :section => root_section, :name => "Test Page", :path => "test")
    @page.create_connector(@block, "main")
    @page.reload
    
    get :usages, :id => @block.id
    
    assert_response :success
    assert_select "td.page_name", "Test Page"
  end

  # Doesn't really belong here, but I'm not sure how else to test the behavior of the form_builders
  def test_form_helpers_which_use_instructions
    get :new, :type=>"login_portlet"
    assert_response :success
    assert_select "div.instructions", "Leave blank to send the user to the page they were trying to access"

  end
end