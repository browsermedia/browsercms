require 'test_helper'

class VersionHistoryTest < ActiveSupport::TestCase
  def setup
    @attachable = create(:versioned_attachable, :attachment_file_path => "/version1.jpg")
    when_attachable_is_updated_to_version2("version2.jpg")

    @version1 = @attachable.as_of_version(1)
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

  test "reverting to original version should also use earlier attachment" do
    assert_equal 2, @attachable.version
    @attachable.revert_to(1)
    @attachable.publish!
    @attachable.reload

    log_table Cms::Attachment
    log_table Cms::Attachment::Version
    assert_equal 3, @attachable.version
    assert_equal "/version1.jpg", @attachable.attachments[0].data_file_path

  end

  private

  def when_attachable_is_updated_to_version2(path)
    @attachable.attachments[0].data_file_path = path
    @attachable.name = "Force Update"
    @attachable.publish_on_save = true
    @attachable.save!
    reset(:attachable)
  end
end