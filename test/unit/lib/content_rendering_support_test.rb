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

  end
end