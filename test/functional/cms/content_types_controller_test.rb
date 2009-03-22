require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::ContentTypesControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def test_select
    @html_block = Factory(:html_block, :name => "HtmlBlock")
    @page = Factory(:page, :section => root_section)

    login_as_cms_admin

    get :index, :connect_to_page_id => @page.to_param, :connect_to_container => "test"
    
    assert_response :success
    assert_select "a[href=?]", /.*html_block%5Bconnect_to_page_id%5D=#{@page.id}.*/, @html_block.display_name
  end  
  
end