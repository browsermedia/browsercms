require 'test_helper'

class VersioningTest < ActiveSupport::TestCase

  test "Saving a new record should create two rows, one in html_blocks, one in html_block_versions" do
    block = HtmlBlock.new(:name=>"Name is required.")
    assert_equal true,  block.save!
    assert_equal 1, block.versions.size
  end

  test "Saving a new Versioned block should allow after_save callbacks to work" do
    block = HtmlBlock.new(:name=>"Testing")
    assert block.save
    assert_equal false, block.skip_callbacks
  end

  test "Saving a block without changing any attributes should skip after_save callbacks" do
    block = HtmlBlock.new(:name=>"Testing")
    block.save

    block.name = "Testing"
    assert block.save

    assert_equal true, block.skip_callbacks
  end

  test "Updating a block should increment the version on the new draft" do
    block = Factory(:html_block)
    assert_equal 1, block.version
    block.name = "New Name"
    assert block.save

    assert_equal 2, block.versions.size
    assert_equal 1, block.versions[0].version
    assert_equal 2, block.versions[1].version
  end

  test "Build new version should create a new version with an incremented version from the primary object" do
    block = HtmlBlock.new(:name=>"ABC")
    assert block.save
    assert_equal 2, block.build_new_version_and_add_to_versions_list_for_saving.version
  end

  test "Updating an object should perform after_save callbacks" do
    block = Factory(:html_block)
    block.name = "New THing"
    block.expects(:update_connected_pages).returns(true)

    block.save
  end
end

class VersionsTest < ActiveSupport::TestCase

  def setup
    @published_block = Factory(:html_block, :name=>"Version 1", :publish_on_save=>true)
    @published_block.update_attributes(:name=>"Version 2")
    @published_block.reload
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