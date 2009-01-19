require File.join(File.dirname(__FILE__), '/../test_helper')

class AttachmentTest < ActiveSupport::TestCase
  test "creating an attachment witn no file" do
    attachment = Attachment.new
    assert_not_valid attachment
    assert_has_error_on attachment, :temp_file, "You must upload a file"
  end
  test "creating an attachment with a StringIO file" do
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
  test "creating an attachment with a Tempfile file" do
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
    assert_equal 2, attachment.version 
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
    assert_equal 3, attachment.version 
    assert_equal "/bar.txt", attachment.file_path
    assert_equal "bar.txt", attachment.file_name
    assert_not_equal original_file_location, attachment.file_location
    assert_equal "This is a new file", open(attachment.full_file_location){|f| f.read}  
  end
  test "find_live_by_file_path" do
    file = ActionController::UploadedTempfile.new("foo.txt")
    open(file.path, 'w') {|f| f << "This is a file"}
    file.original_path = "bar.txt"
    file.content_type = "text/plain"
    attachment = Attachment.new(:temp_file => file, :file_path => "/foo.txt", :section => root_section)
    attachment.save!
    assert !attachment.published?, "Attachment should not be published"
    assert_nil Attachment.find_live_by_file_path("/foo.txt")
    
    attachment.update_attributes(:published => true)
    assert attachment.published?, "Attachment should be published"
    assert_equal attachment, Attachment.find_live_by_file_path("/foo.txt")
    
    attachment.update_attributes(:file_type => "text/html", :published => false)
    assert !attachment.published?, "Attachment should not be published"
    assert_equal attachment.as_of_version(2), Attachment.find_live_by_file_path("/foo.txt")    
  end
  test "update attachment section" do
    file = ActionController::UploadedTempfile.new("foo.txt")
    open(file.path, 'w') {|f| f << "This is a file"}
    file.original_path = "bar.txt"
    file.content_type = "text/plain"
    attachment = Attachment.new(:temp_file => file, :file_path => "/foo.txt", :section => root_section)
    attachment.save!

    new_section = create_section(:parent => root_section, :name => "New")
    assert_equal root_section, attachment.section
    
    attachment.update_attributes!(:section => new_section)
    assert_equal new_section, attachment.section
    
  end
end
