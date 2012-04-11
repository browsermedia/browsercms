require 'test_helper'

class VersionHistoryTest < ActiveSupport::TestCase
  def setup
    @attachable = create(:versioned_attachable, :attachment_file_path => "/version1.jpg")
    when_attachable_is_updated_to_version2("version2.jpg")

    @version1 = @attachable.as_of_version(1)
    assert_equal 2, @attachable.version, "Starting with a block at version 2"

  end

  test "Named .has_attachment methods work for older versions" do
    assert_equal "/version1.jpg", @version1.document.data_file_path
  end

  test ".has_attachment :name add name? method for older versions" do
    assert @version1.document?
  end

  test ".has_attachment :name for missing attachment" do
    assert_nil @version1.attachment_named("not_real_attachment_name")
  end

  test "Versioning.attachments_as_of_version" do
    attachments = VersionedAttachable.attachments_as_of_version(1, @attachable)
    assert_equal 1, attachments.size
    assert_equal '/version1.jpg', attachments[0].data_file_path
    assert_equal Cms::Attachment, attachments[0].class
  end

  test "#attachments for an older version" do
    found = @attachable.as_of_version(1)

    assert_equal Array, found.attachments.class
    assert_equal 1, found.attachments.size
    assert_equal "/version1.jpg", found.attachments[0].data_file_path
  end

  test "#attachments for the current version" do
    found = @attachable.as_of_version(2)
    assert_equal 1, found.attachments.size
    assert_equal "/version2.jpg", found.attachments[0].data_file_path
  end

  test "reverting a block with a single attachment to original version should also use earlier attachment" do
    revert_to_first_version_and_publish

    assert_equal 3, @attachable.version
    assert_equal "/version1.jpg", @attachable.attachments[0].data_file_path
  end

  test "reverting should create a 'clean' version history where each record represents a state change." do
    revert_to_first_version_and_publish

    versions = Cms::Attachment::Version.all
    assert_equal 3, versions.size, "Should be three version records"
    
    last_record = versions.last
    assert_equal 3, last_record.version, "Should be updated to version 3"
    assert_equal @attachable.version, last_record.attachable_version, "Should point to the correct version of the attachable object"
    assert_equal "Reverted to version 1", last_record.version_comment
  end

  private

  def revert_to_first_version_and_publish
      @attachable.revert_to(1)
      @attachable.publish!
      @attachable.reload
  end

  def when_attachable_is_updated_to_version2(path)
    @attachable.attachments[0].data_file_path = path
    @attachable.name = "Force Update"
    @attachable.publish_on_save = true
    @attachable.save!
    reset(:attachable)
  end
end