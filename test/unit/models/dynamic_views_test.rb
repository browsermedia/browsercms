require "test_helper"

class BasicTemplate < Cms::DynamicView

end

class Cms::DynamicViewsTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "version_foreign_key" do
    assert_equal "dynamic_view_id", Cms::PageTemplate.version_foreign_key
  end

  test "resource_name works for non-namespaced templates" do
    assert_equal :basic_templates, BasicTemplate.resource_name
  end

  test "resource_name works for namespaced templates" do
    assert_equal :cms_page_templates, Cms::PageTemplate.resource_name

  end
end