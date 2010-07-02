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
  def test_index_paging
    @page_templates = []
    20.times do |i|
      @page_templates << Factory(:page_template, :name => "test_#{i}")
    end

    def @request.request_uri
      "/cms/page_templates?page=1"
    end

    get :index, :page => 1
    assert_response :success
    # 15 on first page
    assert_equal 15, assigns['views'].length

    def @request.request_uri
      "/cms/page_templates?page=2"
    end

    get :index, :page => 2
    assert_response :success
    # count minus 15 on second page
    should_have = PageTemplate.all.length - 15
    assert_equal should_have, assigns['views'].length
  end  
end
