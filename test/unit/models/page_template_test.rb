require File.join(File.dirname(__FILE__), '/../../test_helper')

class PageTemplateTest < ActiveSupport::TestCase
  def setup
    @page_template = Factory(:page_template, :name => "test")
    File.delete(@page_template.file_path) if File.exists?(@page_template.file_path)
  end
  
  def teardown
    File.delete(@page_template.file_path) if File.exists?(@page_template.file_path)    
  end
  
  def test_create
    assert !File.exists?(@page_template.file_path), "template file already exists"
    assert_valid @page_template
    assert @page_template.save
    assert File.exists?(@page_template.file_path), "template file was not written to disk"
  end
  
  def test_for_valid_name
    assert_not_valid Factory.build(:page_template, :name => "Fancy")
    assert_not_valid Factory.build(:page_template, :name => "foo bar")
    assert_valid Factory.build(:page_template, :name => "subpage_1_column")
  end
  
end