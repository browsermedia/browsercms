require "test_helper"

class BasicTemplate < Cms::DynamicView

end

class Cms::DynamicViewsTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "#form_name" do
    assert_equal "cms_page_template", Cms::PageTemplate.model_name.singular
  end

  test "version_foreign_key" do
    assert_equal :original_record_id, Cms::PageTemplate.version_foreign_key
  end

  test "#route_key" do
    assert_equal "basic_templates", BasicTemplate.model_name.route_key
    assert_equal "page_templates", Cms::PageTemplate.model_name.route_key
    assert_equal "page_partials", Cms::PagePartial.model_name.route_key

  end

  test "#resource_collection_name" do
    assert_equal "page_template", Cms::PageTemplate.model_name.param_key
    assert_equal "page_partial", Cms::PagePartial.model_name.param_key
  end

  test "Display Name" do
    assert_equal "Page Partial", Cms::PagePartial.title
    assert_equal "Page Template", Cms::PageTemplate.title
  end

  test "#deleted blocks don't affect uniqueness validation'" do
    deleted_template = create(:page_template, name: "subpage")
    deleted_template.destroy

    new_template = create(:page_template, name: "subpage")
    assert_not_nil new_template
  end
end