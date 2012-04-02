require 'test_helper'

module Cms
class ConnectorsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    given_there_is_a_content_type Cms::HtmlBlock
    given_there_is_a_content_type Cms::Portlet
    login_as_cms_admin
  end
  
  def test_new
    @page = create(:page, :section => root_section, :name => "Test Page")
    @block = create(:html_block)
    
    get :new, :page_id => @page, :container => "main"

    assert_response :success
    assert_select "title", "Add Existing Content to 'Test Page' Page"
  end
  
  def test_new_portlet
    @page = create(:page, :section => root_section, :name => "Test Page")
    @portlet = create(:portlet, :connect_to_page_id => @page.id, :connect_to_container => "main")
    reset(:page)
    
    get :new, :page_id => @page, :container => "main", :block_type => "portlets"

    assert_response :success
    assert_select "title", "Add Existing Content to 'Test Page' Page"
  end
  
  def test_new_with_deleted_portlet
    @page = create(:page, :section => root_section, :name => "Test Page")
    @portlet = create(:portlet)
    @portlet.destroy
    
    get :new, :page_id => @page, :container => "main", :block_type => "portlets"

    assert_response :success
    assert_select "#dynamic_portlet_#{@portlet.id}", :count => 0
  end
  
  def test_destroy
    @page = create(:page, :section => root_section)
    @block = create(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "main")
    reset(:page)
    
    page_version_count = Page::Version.count
    
    assert_equal 2, @page.draft.version
    
    delete :destroy, :id => @page.connectors.for_page_version(@page.draft.version).first.id
    reset(:page)
    
    assert_redirected_to @page.path
    assert_incremented page_version_count, Page::Version.count
    assert_equal 3, @page.draft.version
    assert @page.connectors.for_page_version(@page.draft.version).empty?
  end
    
end
end
