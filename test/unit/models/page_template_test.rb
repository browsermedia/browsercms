require 'test_helper'

class PageTemplateTest < ActiveSupport::TestCase
  def setup
    @page_template = build(:page_template, :name => "test")
  end

  test "#hint" do
    assert_equal String, @page_template.hint.class
    refute @page_template.hint.blank?
  end

  test "#placeholder" do
    assert_equal String, @page_template.placeholder.class
    refute @page_template.placeholder.blank?
  end

  def test_create_and_destroy
    assert_valid @page_template
    assert @page_template.save
    @page_template.destroy
  end

  def test_for_valid_name
    assert_not_valid build(:page_template, :name => "Fancy")
    assert_not_valid build(:page_template, :name => "foo bar")
    assert_valid build(:page_template, :name => "subpage_1_column")
  end

  def test_find_by_file_name
    assert @page_template.save, "Could not save page template"
    assert_equal @page_template, Cms::PageTemplate.find_by_file_name("test.html.erb")
    assert_nil Cms::PageTemplate.find_by_file_name("fail.html.erb")
    assert_nil Cms::PageTemplate.find_by_file_name("fail.erb")
    assert_nil Cms::PageTemplate.find_by_file_name("fail")
    assert_nil Cms::PageTemplate.find_by_file_name(nil)
  end

  def test_default_body
    assert_not_nil Cms::PageTemplate.default_body
  end

  def test_display_name
    assert_equal "Foo (html/erb)", Cms::PageTemplate.display_name("foo.html.erb")
    assert_equal "Foo (slim)", Cms::PageTemplate.display_name("foo.slim")
  end
end
