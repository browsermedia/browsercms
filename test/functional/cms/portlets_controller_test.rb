require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::PortletsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
    
  def setup
    login_as_cms_admin
    @block = DynamicPortlet.create!(:name => "V1", :code => "@foo = 42", :template => "<%= @foo %>")    
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
  
end