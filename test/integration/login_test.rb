require File.join(File.dirname(__FILE__) + '/../test_helper')

class LoginTest < ActionController::IntegrationTest
  fixtures :all
  
  def test_login
    # get "/cms/login", {}, {"User-Agent" => "Test"}
    # assert_response :success
    # 
    # post_via_redirect "/cms/login", {:login => "cmsadmin", :password => "cmsadmin"}, {"User-Agent" => "Test"}
    # assert_equal '/cms', path
    # assert_equal 'Logged in successfully', flash[:notice]
  end
end
