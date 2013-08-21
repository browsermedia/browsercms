require 'test_helper'

class PagePartialTest < ActiveSupport::TestCase
  def setup
    @page_partial = build(:page_partial)
    File.delete(@page_partial.file_path) if File.exists?(@page_partial.file_path)
  end

  def teardown
    File.delete(@page_partial.file_path) if File.exists?(@page_partial.file_path)
  end

  test "calculates path" do
    @page_partial.save!
    assert_equal "partials/#{@page_partial.name}", @page_partial.path
  end

  test "mass assignment works" do
    Cms::PagePartial.new(:name=>"A", :format=>"B", :handler=>"C", :body=>"D")
    Cms::PageTemplate.new(:name=>"A", :format=>"B", :handler=>"C", :body=>"D")
  end
  test "Name used to build the form" do
    assert_equal "page_partial", Cms::PagePartial.resource_collection_name
  end

  test "resource_name works for namespaced templates" do
    assert_equal "page_partials", Cms::PagePartial.resource_name
  end

  test "create" do
    @page_partial.save!
  end

  def test_create
    assert !File.exists?(@page_partial.file_path), "partial file already exists"
    assert_valid @page_partial
    assert @page_partial.save
    assert File.exists?(@page_partial.file_path), "partial file was not written to disk"
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