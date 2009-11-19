require "test_helper"

class CmsActsAsContentPageTest < ActiveSupport::TestCase

  class MyController < ActionController::Base
    include Cms::Acts::ContentPage
  end

  test "Arbitrary controller should have authentication methods" do
    c = MyController.new

    assert c.respond_to? :handle_access_denied_on_page
    assert c.respond_to? :handle_not_found_on_page
    assert c.respond_to? :handle_server_error_on_page
    assert c.respond_to? :handle_error_with_cms_page, true

    assert(c.respond_to?(:logged_in?), "Should include Cms::Authentication::Controller methods")
    assert(c.respond_to?(:handle_server_error), "Should include Cms::ErrorHandling methods")
  end
end