require File.join(File.dirname(__FILE__), '/../../test_helper')

class VersioningTest < ActiveSupport::TestCase

  test "Saving a new record should create two rows, one in html_blocks, one in html_block_versions" do
    block = HtmlBlock.new(:name=>"Name is required.")
    assert_equal true,  block.save!
    assert_equal 1, block.versions.size
  end

  
end