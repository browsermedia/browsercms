require 'test_helper'

class Cms::PathHelperTest < ActionController::TestCase

  include Cms::PathHelper
  include ActionDispatch::Routing::UrlFor
  #include Rails.application.routes.url_helpers
  #default_url_options[:host] = 'www.example.com'

  def setup
  end

  def teardown
  end

  # These tests are probably redundant now since we have Scenario coverage.
  # However, it will be easier to merge forward with an editted file rather than a deleted one.
  def test_edit_cms_connectable_path_for_portlets
    portlet = DynamicPortlet.create(:name => "Testing Route generation")
    expected_path = "/cms/portlets/#{portlet.id}/edit"
    self.expects(:edit_portlet_path).with(portlet, {}).returns(expected_path)

    path = edit_cms_connectable_path(portlet)

    assert_equal(expected_path, path)
  end

  def test_edit_cms_connectable_path_includes_options_for_portlets
    portlet = DynamicPortlet.create(:name => "Testing Route generation")
    expected_path = "/cms/portlets/#{portlet.id}/edit?_redirect_to=some_path"
    self.expects(:edit_portlet_path).with(portlet, {:_redirect_to => "/some_path"}).returns(expected_path)

    path = edit_cms_connectable_path(portlet, :_redirect_to => "/some_path")

    assert_equal(expected_path, path)
  end

end
