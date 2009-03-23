require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::ConnectorsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_new
    @page = Factory(:page, :section => root_section)
    @block = Factory(:html_block)
    reset(:page)
    
    get :new, :page_id => @page, :container => "main"
    
    assert_response :success
    
  end
  
  def test_destroy
    @page = Factory(:page, :section => root_section)
    @block = Factory(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "main")
    reset(:page)
    
    page_version_count = Page::Version.count
    
    assert_equal 2, @page.version
    
    delete :destroy, :id => @page.connectors.for_page_version(@page.version).first.id
    reset(:page)
    
    assert_redirected_to @page.path
    assert_incremented page_version_count, Page::Version.count
    assert_equal 3, @page.version
    assert @page.connectors.for_page_version(@page.version).empty?
  end
    
end