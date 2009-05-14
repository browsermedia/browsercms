require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::DynamicViewsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    login_as_cms_admin
  end
  
  def test_index
    @deleted_page_template = Factory(:page_template, :name => "deleted")

    @deleted_page_template.destroy
    @page_template = Factory(:page_template, :name => "test")
    
    def @request.request_uri
      "/cms/page_templates"
    end
    get :index
    
    assert_response :success
    #log @response.body
    assert_select "#page_template_#{@page_template.id} div", "Test (html/erb)"
    assert_select "#page_template_#{@deleted_page_template.id} div", 
      :text => "Deleted (html/erb)", :count => 0
  end
  
end