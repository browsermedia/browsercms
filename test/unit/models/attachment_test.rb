require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  test "#attachable_class sets #attachable_type attribute" do
    a = Cms::Attachment.new
    a.attachable_class = Cms::FileBlock
    assert_equal Cms::FileBlock, a.attachable_type
  end

  test "Attachments are configured" do
    assert attachment.respond_to?(:data), "Attachment.configure was not called during setup, so attachments were not configured properly."
  end

  test "#attachable_version records which version of the block this attachment was connected to." do
    assert attachment.respond_to?(:attachable_version)
  end

  test "File/Image blocks require a path to be valid" do
    attachment.attachable_type = 'Cms::AbstractFileBlock'
    assert_not_valid attachment
    assert_has_error_on attachment, :data_file_path, "can't be blank"
  end

  test "#data is a..." do
    assert_equal Paperclip::Attachment, attachment.data.class
  end

  test "#data is missing" do
    refute attachment.data.exists?, "Starts as an 'Empty' attachment"
  end

  test "#data=" do
    attachment.data = nil
    refute attachment.data.exists?
  end

  test "#is_image? for missing extension" do
    attachment.data_file_name = "missing_extension"
    assert_equal false, attachment.is_image?
  end

  test "#is_image? for NULL name" do
    attachment.data_file_name = nil
    assert_equal false, attachment.is_image?
  end

  test "#is_image?" do
    attachment.data_file_name = "hello.jpg"
    assert_equal true, attachment.is_image?
  end

  test "#ensure_sanitized_file_path doesn't replace empty paths'" do
    attachment.data_file_path = ""
    attachment.send(:sanitized_file_path_and_name)

    assert_equal "", attachment.data_file_path
  end

  test "attachable_version should be nil until its associated with a content block" do
    attachment.valid?
    assert_nil attachment.attachable_version
  end

  test "Sanitize file name" do
    file_attachment.data_file_name = "Something #With ?Spaces"
    file_attachment.save!

    assert_equal "Something_With_Spaces", file_attachment.data_file_name
  end

  def file_attachment
    return @file_attachment if @file_attachment
    find_or_create_root_section
    @file_attachment = Cms::Attachment.new(:attachment_name => "file", :attachable_type => "Cms::FileBlock", :parent => Cms::Section.first)
  end

  private

  def attachment
    @attachment ||= Cms::Attachment.new
  end
end

class AttachmentsValidation < ActiveSupport::TestCase

  def setup
    @valid_attachment = Cms::Attachment.new
    @valid_attachment.attachment_name = "anything"
    @valid_attachment.attachable_type = "VersionedAttachable"
  end

  test "Valid" do
    assert @valid_attachment.valid?
  end

  test "Must have an attachment_name" do
    @valid_attachment.attachment_name = nil
    refute @valid_attachment.valid?
  end

  test "Must have content_block_class" do
    @valid_attachment.attachable_type = nil
    refute @valid_attachment.valid?
  end


end
