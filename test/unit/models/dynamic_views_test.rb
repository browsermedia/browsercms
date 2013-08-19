require "test_helper"

class BasicTemplate < Cms::DynamicView

end

class Cms::DynamicViewsTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "#form_name" do
    assert_equal "cms_page_template", Cms::PageTemplate.form_name
  end

  test "version_foreign_key" do
    assert_equal :original_record_id, Cms::PageTemplate.version_foreign_key
  end

  test "resource_name works for non-namespaced templates" do
    assert_equal "basic_templates", BasicTemplate.resource_name
  end

  test "Engine" do
    assert_equal "cms", Cms::DynamicView.engine
    assert_equal "cms", Cms::PageTemplate.engine
    assert_equal "cms", Cms::PagePartial.engine
  end

  test "path_elements" do
    assert_equal [Cms::PageTemplate], Cms::PageTemplate.path_elements
    assert_equal [Cms::PagePartial], Cms::PagePartial.path_elements

  end

  test "Display Name" do
    assert_equal "Page Partial", Cms::PagePartial.title
    assert_equal "Page Template", Cms::PageTemplate.title
  end
end