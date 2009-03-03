require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::CacheControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_expire_cache
    #TODO: Implement Cache Expiration
  end
  
end