require "test_helper"

class ContentRenderingSupportTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "still has error handling methods" do
    c = Cms::ContentController.new
    
    assert c.respond_to? :handle_access_denied_on_page
    assert c.respond_to? :handle_not_found_on_page
    assert c.respond_to? :handle_server_error_on_page
    assert c.respond_to? :handle_error_with_cms_page, true

    assert(c.respond_to?(:logged_in?), "Should include Cms::Authentication::Controller methods")
  end

  class MyController < ActionController::Base
    include Cms::ContentRenderingSupport
  end

  test "Arbitrary controller should have authentication methods" do
    c = MyController.new

    assert c.respond_to? :handle_access_denied_on_page
    assert c.respond_to? :handle_not_found_on_page
    assert c.respond_to? :handle_server_error_on_page
    assert c.respond_to? :handle_error_with_cms_page, true

    assert(!c.respond_to?(:logged_in?), "Should Not include Cms::Authentication::Controller methods")
    assert(c.respond_to?(:handle_server_error), "Should include Cms::ErrorHandling methods")
  end

end