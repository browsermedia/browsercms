require 'test_helper'

class Tests::PretendControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    remove_all_sitemap_fixtures_to_avoid_bugs
    given_a_site_exists
  end

  test "open" do
    get :open
    assert_response :success
    assert_select 'h1', "Open Page"
  end

  test "restricted members section should give standard CMS error page when not logged in" do
    restricted_section = Factory(:section, :path=>"/members")

    get :restricted
    assert_response 403
    assert_select 'title', "Access Denied"
  end

  test "restricted page should be visible to cmsadmins" do
    restricted_section = Factory(:section, :path=>"/members")
    login_as_cms_admin

    get :restricted
    assert_response :success
    assert_select "h1", Tests::PretendController::RESTRICTED_H1
  end

  # Matches content_controller_test
  test "not-found when not logged in" do
    get :not_found
    assert_response :missing
    assert_select "title", "Not Found"
  end

  # See content_controller_tests for similar behavio
  test "Throwing NotFound while logged in as admin will render error rather than 404 page." do
    login_as_cms_admin

    get :not_found

    assert_response :error, "Unlike ContentController Acts::ContentPage will have an error rather than 404 page."
    assert_select "title", "Error: ActiveRecord::RecordNotFound"
  end


  test "error" do
    get :error
    assert_response :error
    assert_select "title", "Server Error"
  end
end
