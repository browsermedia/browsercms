require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::ToolbarControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    login_as_cms_admin
  end
  
  def test_index_for_published_page
    create_page
    @page.publish!
    reset(:page)
    
    get :index, :page_id => @page.id, :page_version => @page.version, :mode => "edit"
    
    assert_response :success
    #log @response.body
    assert_select "#page_status", "published"
    assert_select "#section_link" do
      assert_select "a[href=?]", "/cms/sections?page_id=#{@page.id}"
      assert_select "a", @page.section.name
    end
    assert_select ".buttons .disabled span", "Publish"
    
    assert_select ".buttons .disabled span", :text => "Edit Properties", :count => 0
    assert_select "#edit_properties_button[href=?]", edit_cms_page_path(@page)
    
    assert_select "#visual_editor_state", "ON"
    assert_select "#visual_editor_action", "TURN OFF"
  end
  
  def test_index_for_draft_page
    create_page
    
    get :index, :page_id => @page.id, :page_version => @page.version, :mode => "edit"
    
    assert_response :success
    #log @response.body
    assert_select "#page_status", "draft"
    assert_select "#section_link" do
      assert_select "a[href=?]", "/cms/sections?page_id=#{@page.id}"
      assert_select "a", @page.section.name
    end
    
    assert_select ".buttons .disabled span", :text => "Publish", :count => 0
    assert_select "#publish_button[href=?]", publish_cms_page_path(@page)
    
    assert_select ".buttons .disabled span", :text => "Edit Properties", :count => 0
    assert_select "#edit_properties_button[href=?]", edit_cms_page_path(@page)
    
    assert_select ".buttons span", :text => "Revert to this Version", :count => 0
    assert_select "#delete_button", 1
    
    assert_select "#visual_editor_state", "ON"
    assert_select "#visual_editor_action", "TURN OFF"    
  end
    
  protected
    def create_page
      @page = Factory(:page, :section => root_section, :name => "Test", :path => "test")      
    end  
  
end