require "test_helper"

class VersioningTest < ActiveSupport::TestCase

  def setup
    @published_block = Factory(:html_block, :name=>"Version 1", :publish_on_save=>true)
    @published_block.update_attributes(:name=>"Version 2")
    @published_block.reload
  end

  def teardown
  end


  test "#name matches original version's attributes'" do
    assert_equal "Version 1", @published_block.name
  end

  test "#as_of_draft_version" do
    v2 = @published_block.as_of_draft_version
    assert_equal "Version 2", v2.name
    assert_equal HtmlBlock, v2.class
  end

  test "#draft returns the latest Version Object for a block" do
    v2 = @published_block.draft
    assert_equal "Version 2", v2.name
    assert_equal HtmlBlock::Version, v2.class
  end

  test "#as_of_version" do
    v1 = @published_block.as_of_version(1)
    assert_equal "Version 1", v1.name
    assert_equal @published_block.id, v1.id
  end
end