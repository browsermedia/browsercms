require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::CategoriesControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
  end
  
  def test_new_with_no_category_types
    assert_equal 0, CategoryType.count, "This test depends on there being no category types"
    get :new
    assert_response :success
    assert_select "title", "Please Create A Category Type"
  end
  
  def test_new_with_category_types
    Factory(:category_type, :name => "FooCategoryType")
    get :new
    assert_response :success
    assert_select "title", "Content Library / Add New Category"
    assert_select "option", "FooCategoryType"
  end
  
end