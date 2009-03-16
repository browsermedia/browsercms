require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::ConnectorsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
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
  
  def test_usages
    @page = Factory(:page, :section => root_section, :name => "Included")
    @page2 = Factory(:page, :section => root_section, :path => "/other_path", :name => "Excluded")
    @block = Factory(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "main")
    
    get :usages, :id => @block.id, :block_type => "html_block"

    assert_response :success
    assert_select "h1", "Pages Using Text '#{@block.name}'"
    assert_select "td.page_name", "Included"
    assert_select "td.page_name", {:count => 0, :text => "Excluded"}
    assert_select "h3", "Content Types"
  end
  
end