require 'test_helper'

module Cms
class CacheControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_expire_cache
    #TODO: Implement Cache Expiration
  end
  
end
end
