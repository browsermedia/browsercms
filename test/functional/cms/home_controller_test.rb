require 'test_helper'

module Cms
class HomeControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  test "behavior of request" do
    @request.host = "www.browsercms.org"
    @request.path = "/something"
    assert_equal @request.url, "http://www.browsercms.org/something"
  end
  def test_cms_site_with_public_site
    @request.host = "foo.com"
    assert !@controller.send(:cms_site?)
  end
  
  def test_cms_site_with_public_site_www
    @request.host = "www.foo.com"
    assert !@controller.send(:cms_site?)
  end
  
  def test_cms_site_with_cms_site
    @request.host = "cms.foo.com"
    assert @controller.send(:cms_site?)
  end
  
  def test_cms_site_with_cms_site_www
    @request.host = "www.cms.foo.com"
    assert @controller.send(:cms_site?)    
  end
  
  def test_url_with_cms_domain_prefix_with_public_site
    @request.host = "foo.com"
    @request.path = "/cms"
    assert_equal "http://cms.foo.com/cms", 
      @controller.send(:url_with_cms_domain_prefix)
  end
  
  def test_url_with_cms_domain_prefix_with_public_site_www
    @request.host = "www.foo.com"
    @request.path = "/cms"
    assert_equal "http://cms.foo.com/cms", @controller.send(:url_with_cms_domain_prefix)
  end

  def test_url_with_cms_domain_prefix_with_cms_site
    @request.host = "cms.foo.com"
    @request.path = "/cms"

    assert_equal "http://cms.foo.com/cms", @controller.send(:url_with_cms_domain_prefix)
  end

  def test_url_with_cms_domain_prefix_with_cms_site_www
    @request.host = "www.cms.foo.com"
    @request.path = "/cms"
    assert_equal "http://www.cms.foo.com/cms", @controller.send(:url_with_cms_domain_prefix)
  end
  
  def test_redirected_to_cms_site_if_public_site
    @request.host = "foo.com"
    get :index
    assert_redirected_to "http://foo.com/cms/users/login"
  end

  def test_redirected_to_cms_site_if_public_site_and_logged_in
    login_as_cms_admin
    @request.host = "foo.com"
    get :index
    assert_redirected_to "http://foo.com/"
  end
  
  def test_success_if_cms_site_and_logged_in
    login_as_cms_admin    
    @request.host = "cms.foo.com"    
    get :index
    assert_redirected_to "http://cms.foo.com/"
  end  
  
end

class HomeControllerCachingEnabledTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  tests Cms::HomeController
  
  def setup
    @controller.perform_caching = true
  end
  
  def teardown
    @controller.perform_caching = false
  end
  
  def test_cms_site_with_public_site
    @request.host = "foo.com"
    assert !@controller.send(:cms_site?)
  end
  
  def test_cms_site_with_public_site_www
    @request.host = "www.foo.com"
    assert !@controller.send(:cms_site?)
  end
  
  def test_cms_site_with_cms_site
    @request.host = "cms.foo.com"
    assert @controller.send(:cms_site?)
  end
  
  def test_cms_site_with_cms_site_www
    @request.host = "www.cms.foo.com"
    assert @controller.send(:cms_site?)    
  end
  
  def test_url_with_cms_domain_prefix_with_public_site
    @request.host = "foo.com"
    @request.path = "/cms"
    assert_equal "http://cms.foo.com/cms", 
      @controller.send(:url_with_cms_domain_prefix)
  end
  
  test "url_with_cms_domain_prefix_with_public_site_www" do
    @request.host = "www.foo.com"
    @request.path = "/cms"
    assert_equal "http://cms.foo.com/cms",  @controller.send(:url_with_cms_domain_prefix)
  end

  def test_url_with_cms_domain_prefix_with_cms_site
    @request.host = "cms.foo.com"
    @request.path = "/cms"
    assert_equal "http://cms.foo.com/cms", 
      @controller.send(:url_with_cms_domain_prefix)
  end

  def test_url_with_cms_domain_prefix_with_cms_site_www
    @request.host = "www.cms.foo.com"
    @request.path = "/cms"
    assert_equal "http://www.cms.foo.com/cms", @controller.send(:url_with_cms_domain_prefix)
  end
  
  def test_success_if_cms_site_and_logged_in
    login_as_cms_admin    
    @request.host = "cms.foo.com"    
    get :index
    assert_redirected_to "http://cms.foo.com/"
  end  
  
end
end
