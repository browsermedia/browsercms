require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::SessionsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def test_not_redirected_to_cms_site_if_public_site
    @request.host = "foo.com"
    @request.request_uri = "/cms/login"
    get :new
    assert_response :success
  end

  def test_not_redirected_if_cms_site
    @request.host = "cms.foo.com"
    @request.request_uri = "/cms/login"
    get :new
    assert_response :success
    log @response.body
    assert_select "title", "CMS Login"
  end
  
end

class Cms::SessionsControllerCacheEnabledTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  tests Cms::SessionsController
  
  def setup
    @controller.perform_caching = true
  end
  
  def teardown
    @controller.perform_caching = false
  end
  
  def test_redirected_to_cms_site_if_public_site
    @request.host = "foo.com"
    @request.request_uri = "/cms/login"
    get :new
    assert_redirected_to "http://cms.foo.com/cms/login"
  end

  def test_not_redirected_if_cms_site
    @request.host = "cms.foo.com"
    @request.request_uri = "/cms/login"
    get :new
    assert_response :success
    log @response.body
    assert_select "title", "CMS Login"
  end
  
end