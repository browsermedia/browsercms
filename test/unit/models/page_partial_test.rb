require File.join(File.dirname(__FILE__), '/../../test_helper')

class PagePartialTest < ActiveSupport::TestCase
  def setup
    @page_partial = Factory.build(:page_partial, :name => "_test")
    File.delete(@page_partial.file_path) if File.exists?(@page_partial.file_path)
  end
  
  def teardown
    File.delete(@page_partial.file_path) if File.exists?(@page_partial.file_path)    
  end
  
  def test_create
    assert !File.exists?(@page_partial.file_path), "partial file already exists"
    assert_valid @page_partial
    assert @page_partial.save
    assert File.exists?(@page_partial.file_path), "partial file was not written to disk"
  end
  
  def test_for_valid_name
    assert_not_valid Factory.build(:page_partial, :name => "Fancy")
    assert_not_valid Factory.build(:page_partial, :name => "foo bar")
    partial = Factory.build(:page_partial, :name => "subpage_1_column")
    assert_valid partial
    assert_equal "_subpage_1_column", partial.name
    assert_valid Factory.build(:page_partial, :name => "_sidebar")
  end
  
end