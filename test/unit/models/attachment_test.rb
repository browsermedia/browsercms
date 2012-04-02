require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  def attachment
    @attachment ||= Cms::Attachment.new
  end

  def test_requires_data_file_path_if_abstract_file_block
    attachment.attachable_type = 'AbstractFileBlock'
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


  # def test_creating_an_attachment_with_a_StringIO_file
  #   file = @file
  #   attachment = Cms::Attachment.new(:data => file,
  #                                    :data_file_path => "/sample_upload.txt",
  #                                    :attachment_name => "file",
  #                                    :section => root_section)

  #   attachment.save!
  # assert_equal "sample_upload.txt", attachment.file_name
  # assert_equal "text/plain", attachment.file_type
  # assert_equal "txt", attachment.file_extension
  # assert_file_exists attachment.full_file_location
  # assert_equal "This is a file.", open(attachment.full_file_location) { |f| f.read }
  # end

  #   def test_creating_an_attachment_with_a_Tempfile_file
  #     attachment = Cms::Attachment.new(:temp_file => @file, :file_path => "/foo.txt", :section => root_section)
  #     attachment.save!

  #     assert_equal "foo.txt", attachment.file_name
  #     assert_file_exists attachment.full_file_location
  #     assert_equal "This is a file.", open(attachment.full_file_location) { |f| f.read }

  #     # If you change the attributes of the attachment, but don't change the file
  #     # the file_location should not change
  #     original_file_location = attachment.file_location
  #     attachment = Cms::Attachment.find(attachment.id)
  #     attachment.update_attributes(:file_path => "bar.txt")
  #     assert_equal 2, attachment.draft.version
  #     assert_equal "/bar.txt", attachment.file_path
  #     assert_equal "bar.txt", attachment.file_name
  #     assert_equal original_file_location, attachment.file_location
  #   end

  #   def test_updating_a_new_file_should_change_the_file_location
  #     attachment = Cms::Attachment.create!(:temp_file => @file, :file_path => "/foo.txt", :section => root_section)

  #     reloaded_attachment = Cms::Attachment.find(attachment.id)
  #     original_file_location = attachment.file_location
  #     file = file_upload_object(:original_filename=>"second_upload.txt", :content_type=>"text/plain")
  #     reloaded_attachment.update_attributes(:temp_file => file)
  #     assert_equal 2, reloaded_attachment.draft.version
  #     assert_equal "/foo.txt", reloaded_attachment.as_of_draft_version.file_path, "Updating the file itself should also update the name of the file. (Note:This might just be an invalid test)"
  #     assert_equal "foo.txt", reloaded_attachment.as_of_draft_version.file_name
  #     assert_not_equal original_file_location, reloaded_attachment.as_of_draft_version.file_location
  #     assert_equal "This is a second file.", open(reloaded_attachment.as_of_draft_version.full_file_location) { |f| f.read }
  #   end

  #   def test_find_live_by_file_path
  #     file = @file
  #     attachment = Cms::Attachment.new(:temp_file => file, :file_path => "/foo.txt", :section => root_section)
  #     attachment.save!
  #     assert !attachment.published?, "Attachment should not be published"
  #     assert_nil Cms::Attachment.find_live_by_file_path("/foo.txt")

  #     attachment.publish
  #     assert attachment.reload.published?, "Attachment should be published"
  #     assert_equal attachment, Cms::Attachment.find_live_by_file_path("/foo.txt")

  #     attachment.update_attributes(:file_type => "text/html")
  #     assert !attachment.live?, "Attachment should not be live"
  #     assert_equal attachment.as_of_version(2), Cms::Attachment.find_live_by_file_path("/foo.txt")
  #   end


  #   test "If an uploaded file has no detectable content type (i.e. markdown) then assign it the 'unknown' type" do
  #     mock_file = mock()
  #     mock_file.expects(:content_type).returns(nil)
  #     atk = Cms::Attachment.new(:temp_file => mock_file)
  #     atk.extract_file_type_from_temp_file

  #     assert_equal Cms::Attachment::UNKNOWN_MIME_TYPE, atk.file_type
  #   end
  # end

  # class Cms::Attachment::SectionTest < ActiveSupport::TestCase

  #   def setup
  #     @file = file_upload_object({:original_filename=>"sample_upload.txt", :content_type=>"text/plain"})
  #     @attachment = Cms::Attachment.create!(:temp_file => @file, :file_path => "/foo.txt", :section => root_section)
  #     @attachment = Cms::Attachment.find(@attachment.id) # Force reload
  #   end

  #   test "Setting the section on an attachment persists that section" do
  #     assert_equal root_section, @attachment.section, "Should be associated with the root section"
  #   end

  #   test "Replacing an existing section should update it" do
  #     new_section = create(:section)
  #     @attachment.section = new_section
  #     @attachment.save!
  #     @attachment = Cms::Attachment.find(@attachment.id) # Force reload
  #     assert_equal new_section, @attachment.section
  #   end
end
