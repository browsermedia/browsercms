require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::SessionsControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  def teardown
    User.current = nil
  end
  
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
  
  def test_return_to
    user = Factory(:user)
    expected_url = "/expected_url"

    post :create, {:success_url => "", :login => user.login, :password => "password"}, {:return_to => expected_url }
    assert_redirected_to(expected_url)
  end
  def test_success_url_overrides_return_to
    user = Factory(:user)
    expected_url = "/expected_url"

    post :create, {:success_url => expected_url, :login => user.login, :password => "password"}, {:return_to => "/somewhere_else" }

    assert_redirected_to(expected_url)
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

  test "destroy" do
    Cms::SessionsController.any_instance.expects(:logout_user)
    delete :destroy
    assert_redirected_to "/" 
  end
end
