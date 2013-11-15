require 'test_helper'

class PagePartialTest < ActiveSupport::TestCase
  def setup
    @page_partial = build(:page_partial)
  end

  test "#hint" do
    assert_equal String, @page_partial.hint.class
    refute @page_partial.hint.blank?
  end

  test "#placeholder" do
    assert_equal String, @page_partial.placeholder.class
    refute @page_partial.placeholder.blank?
  end

  test "calculates path" do
    @page_partial.save!
    assert_equal "partials/#{@page_partial.name}", @page_partial.path
  end

  test "mass assignment works" do
    Cms::PagePartial.new(:name=>"A", :format=>"B", :handler=>"C", :body=>"D")
    Cms::PageTemplate.new(:name=>"A", :format=>"B", :handler=>"C", :body=>"D")
  end

  test "create" do
    @page_partial.save!
  end

  def test_create
    assert_valid @page_partial
    assert @page_partial.save
  end

  def test_for_valid_name
    assert_not_valid build(:page_partial, :name => "Fancy")
    assert_not_valid build(:page_partial, :name => "foo bar")
    partial = build(:page_partial, :name => "subpage_1_column")
    assert_valid partial
    assert_equal "_subpage_1_column", partial.name
    assert_valid build(:page_partial, :name => "_sidebar")
  end

end