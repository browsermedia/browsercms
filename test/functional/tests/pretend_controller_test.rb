require 'test_helper'

class Tests::PretendControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  test "open" do
    get :open
    assert_response :success
    assert_select 'h1', "Open Page"
  end

  test "restricted page should be visible to cmsadmins" do
    restricted_section = Factory(:section, :path=>"/members")
    login_as_cms_admin

    get :restricted
    assert_response :success
    assert_select "h1", Tests::PretendController::RESTRICTED_H1
  end


  # See content_controller_tests for similar behavio
  test "Throwing NotFound while logged in as admin will render error rather than 404 page." do
    login_as_cms_admin

    get :not_found

    assert_response :error, "Unlike ContentController Acts::ContentPage will have an error rather than 404 page."
    assert_select "title", "Error: ActiveRecord::RecordNotFound"
  end

end
