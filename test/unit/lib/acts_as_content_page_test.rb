require "test_helper"
require "mocha"

class CmsActsAsContentPageTest < ActiveSupport::TestCase
  EXPECTED_SECTION = "/members"

  class MyController < ActionController::Base
    include Cms::Acts::ContentPage
    requires_permission_for_section EXPECTED_SECTION
  end

  test "Arbitrary controller should have authentication methods" do
    c = MyController.new

    assert c.respond_to? :handle_access_denied_on_page
    assert c.respond_to? :handle_not_found_on_page
    assert c.respond_to? :handle_server_error_on_page
    assert c.respond_to? :handle_error_with_cms_page, true

    assert(c.respond_to?(:logged_in?), "Should include Cms::Authentication::Controller methods")
    assert(c.respond_to?(:handle_server_error), "Should include Cms::ErrorHandling methods")

    assert(MyController.respond_to?(:requires_permission_for_section), "Should add ClassMethods to the controller.")
  end

  test "check_access_to_section_filter" do
    mock_user = mock()
    mock_user.expects(:able_to_view?).with(EXPECTED_SECTION).returns(true)
    mock_user.expects(:login).returns("mock_user_name")
    c = MyController.new
    c.expects(:current_user).returns(mock_user)


    c.check_access_to_section


  end

  test "sets section in startup" do
    class AController < ActionController::Base
      include Cms::Acts::ContentPage
      requires_permission_for_section EXPECTED_SECTION
    end

    assert_equal EXPECTED_SECTION, AController.in_section
  end

  class NewController < ActionController::Base
      include Cms::Acts::ContentPage
  end

  test "placing in a section should create a before_filter for that section for all actions" do
    NewController.expects(:before_filter).with(:check_access_to_section, {})

    NewController.send :requires_permission_for_section, EXPECTED_SECTION

  end

  test "can put only conditions on filters" do
    NewController.expects(:before_filter).with(:check_access_to_section, :only=>[:create])

    NewController.send :requires_permission_for_section, EXPECTED_SECTION, :only=>[:create]
  end

  test "can put except conditions on filters" do
    NewController.expects(:before_filter).with(:check_access_to_section, :except=>[:create])

    NewController.send :requires_permission_for_section, EXPECTED_SECTION, :except=>[:create]
  end


end