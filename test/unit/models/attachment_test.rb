require File.join(File.dirname(__FILE__), '/../../test_helper')

class AttachmentTest < ActiveSupport::TestCase
  
  def test_creating_an_attachment_witn_no_file
    attachment = Attachment.new
    assert_not_valid attachment
    assert_has_error_on attachment, :temp_file, "You must upload a file"
  end
  
  def test_creating_an_attachment_with_a_StringIO_file
    file = ActionController::UploadedStringIO.new("This is a file")
    file.original_path = "bar.txt"
    file.content_type = "text/plain"
    attachment = Attachment.new(:temp_file => file, :file_path => "/foo.txt", :section => root_section)
    attachment.save!
    assert_equal "foo.txt", attachment.file_name
    assert_equal "text/plain", attachment.file_type
    assert_equal "txt", attachment.file_extension
    assert_file_exists attachment.full_file_location
    assert_equal "This is a file", open(attachment.full_file_location){|f| f.read}
  end
  
  def test_creating_an_attachment_with_a_Tempfile_file
    file = ActionController::UploadedTempfile.new("foo.txt")
    open(file.path, 'w') {|f| f << "This is a file"}
    file.original_path = "bar.txt"
    file.content_type = "text/plain"
    attachment = Attachment.new(:temp_file => file, :file_path => "/foo.txt", :section => root_section)
    attachment.save!
  
    assert_equal "foo.txt", attachment.file_name
    assert_file_exists attachment.full_file_location
    assert_equal "This is a file", open(attachment.full_file_location){|f| f.read}
    
    # If you change the attributes of the attachment, but don't change the file
    # the file_location should not change
    original_file_location = attachment.file_location
    attachment = Attachment.find(attachment.id)
    attachment.update_attributes(:file_path => "bar.txt")
    assert_equal 2, attachment.draft.version
    assert_equal "/bar.txt", attachment.file_path
    assert_equal "bar.txt", attachment.file_name
    assert_equal original_file_location, attachment.file_location
    
    # If you change the file of the attachment, the file_location should change
    attachment = Attachment.find(attachment.id)
    file = ActionController::UploadedTempfile.new("foo.txt")
    open(file.path, 'w') {|f| f << "This is a new file"}
    file.original_path = "foo.txt"
    file.content_type = "text/plain"    
    attachment.update_attributes(:temp_file => file)
    # log_table_with Attachment, :id, :name, :version, :file_path
    # log_table_with Attachment::Version, :id, :name, :version, :file_path, :attachment_id
    assert_equal 3, attachment.draft.version 
    assert_equal "/foo.txt", attachment.as_of_draft_version.file_path
    assert_equal "foo.txt", attachment.as_of_draft_version.file_name
    assert_not_equal original_file_location, attachment.as_of_draft_version.file_location
    assert_equal "This is a new file", open(attachment.as_of_draft_version.full_file_location){|f| f.read}  
  end

end

class AttachmentRelations < ActiveSupport::TestCase

  def setup
    @file = ActionController::UploadedTempfile.new("foo.txt")
    open(@file.path, 'w') {|f| f << "This is a file"}
    @file.original_path = "bar.txt"
    @file.content_type = "text/plain"
    @attachment = Attachment.new(:temp_file => @file, :file_path => "/foo.txt", :section => root)
    @attachment.save!
  end

  test "New Attachment" do
    a = Attachment.new
    a.section = root
    assert_equal root, a.section
  end

  test "Attachments should be associated with a section" do
    assert_not_nil @attachment.section_node
    assert_not_nil @attachment.section_node.parent
    assert_equal root, @attachment.section
  end

  test "Attachment should be unpublished and unfindable" do
    assert !@attachment.published?, "Attachment should not be published"
    assert_nil Attachment.find_live_by_file_path("/foo.txt")
  end

  test "Publishing an attachment should make it findable" do
    @attachment.publish
    assert @attachment.reload.published?, "Attachment should be published"
    assert_equal @attachment, Attachment.find_live_by_file_path("/foo.txt")
  end

  test "Changing but not republishing an attachment should keep old version live" do
    @attachment.publish
    assert_equal @root, @attachment.section
    @attachment.update_attributes!(:file_type => "text/html")
    assert !@attachment.live?, "Attachment should not be live"
    assert_equal @attachment.as_of_version(2), Attachment.find_live_by_file_path("/foo.txt")
  end

  test "Updating the section" do
    new_section = Factory(:section, :name => "New")
    @attachment.update_attributes!(:section => new_section)
    assert_equal new_section, @attachment.section
  end
  private

  def root
    @root ||= Factory :root_section
  end
end