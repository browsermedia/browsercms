require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::DashboardControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_index
    get :index
    
    assert_response :success
    assert_select "title", "Dashboard"
  end

  # This is a bit of a hack. Ideally would like the entire
  # test suite to run against both MySQL and SQLite
  # But this was the only SQLite test to fail.
  def test_index_with_sqlite
    ActiveRecord::Base.establish_connection(:test_sqlite3)
    test_index
  end
end