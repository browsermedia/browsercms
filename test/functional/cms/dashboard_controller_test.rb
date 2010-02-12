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
  #
  # If this test fails with a "no such table" error, you 
  # will need to load the sqlite3 test database (most easily
  # by switching the test database to use sqlite3 and running
  # rake).  After you do that, you can switch
  # the test database configuration back.
  def test_index_with_sqlite
    ActiveRecord::Base.establish_connection(:test_sqlite3)
    begin
      test_index
    ensure
      ActiveRecord::Base.establish_connection(:test)
    end
  end
end
