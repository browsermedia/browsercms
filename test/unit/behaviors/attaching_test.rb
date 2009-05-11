require File.join(File.dirname(__FILE__), '/../../test_helper')

ActiveRecord::Base.connection.instance_eval do
  drop_table(:default_attachables) if table_exists?(:default_attachables)
  drop_table(:default_attachable_versions) if table_exists?(:default_attachable_versions)
  create_versioned_table(:default_attachables) do |t| 
    t.string :name
    t.integer :attachment_id
    t.integer :attachment_version
    t.timestamps
  end
  
  drop_table(:versioned_attachables) if table_exists?(:versioned_attachables)
  drop_table(:versioned_attachable_versions) if table_exists?(:versioned_attachable_versions)
  create_versioned_table(:versioned_attachables) do |t| 
    t.string :name
    t.integer :attachment_id
    t.integer :attachment_version
    t.timestamps
  end
  
  drop_table(:versioned_attachables) if table_exists?(:versioned_attachables)
  drop_table(:versioned_attachable_versions) if table_exists?(:versioned_attachable_versions)
  create_versioned_table(:versioned_attachables) do |t| 
    t.string :name
    t.integer :attachment_id
    t.integer :attachment_version
    t.timestamps
  end
  
end

class DefaultAttachable < ActiveRecord::Base
  acts_as_content_block :belongs_to_attachment => true
end

class VersionedAttachable < ActiveRecord::Base
  acts_as_content_block :belongs_to_attachment => true
  
  def set_attachment_file_path
    if @attachment_file_path && @attachment_file_path != attachment.file_path
      attachment.file_path = @attachment_file_path
    end
  end

  def set_attachment_section
    if @attachment_section_id && @attachment_section_id != attachment.section_id
      attachment.section_id = @attachment_section_id 
    end
  end
end

class DefaultAttachableTest < ActiveSupport::TestCase
  def setup
    #file is a mock of the object that Rails wraps file uploads in
    @file = file_upload_object(:original_filename => "foo.jpg",
      :content_type => "image/jpeg", :rewind => true,
      :size => "99", :read => "01010010101010101")

    @section = root_section
  end
  
  def test_create_with_attachment_file
    @attachable = DefaultAttachable.new(:name => "File Name", 
      :attachment_file => @file, :publish_on_save => true)

    attachable_count = DefaultAttachable.count

    assert_valid @attachable
    @attachable.save!

    assert_incremented attachable_count, DefaultAttachable.count
    assert_equal @section, @attachable.attachment_section
    assert_equal @section.id, @attachable.attachment_section_id
    assert_equal "/attachments/foo.jpg", @attachable.attachment_file_path

    reset(:attachable)

    assert_equal @section, @attachable.attachment_section
    assert_equal @section.id, @attachable.attachment_section_id
    assert_equal "/attachments/foo.jpg", @attachable.attachment_file_path
    assert @attachable.attachment.published?
  end  
  
  
end

class AttachingTest < ActiveSupport::TestCase
  
  def test_block_without_attaching_behavior
    assert !HtmlBlock.belongs_to_attachment?
  end
  
  def test_file_path_sanitization
    {
      "Draft #1.txt" => "Draft_1.txt",
      "Copy of 100% of Paul's Time(1).txt" => "Copy_of_100_of_Pauls_Time-1-.txt"
    }.each do |example, expected|
      assert_equal expected, 
        VersionedAttachable.new.sanitize_file_path(example)
    end
  end
  
end

class AttachableTest < ActiveSupport::TestCase
  def setup
    #file is a mock of the object that Rails wraps file uploads in
    @file = file_upload_object(:original_filename => "foo.jpg",
      :content_type => "image/jpeg", :rewind => true,
      :size => "99", :read => "01010010101010101")

    @section = Factory(:section, :name => "attachables", :parent => root_section)    
  end
  
  def test_create_with_attachment_section_id_attachment_file_and_attachment_file_path
    @attachable = VersionedAttachable.new(:name => "Section ID, File and File Name", 
      :attachment_section_id => @section.id, 
      :attachment_file => @file, 
      :attachment_file_path => "test.jpg")

    assert_was_saved_properly
  end  
  
  def test_create_with_attachment_section_attachment_file_and_attachment_file_path
    @attachable = VersionedAttachable.new(:name => "Section, File and File Name", 
     :attachment_section => @section, 
     :attachment_file => @file, 
     :attachment_file_path => "test.jpg")
    
    assert_was_saved_properly
  end
  
  def test_create_with_an_attachment_section_but_no_attachment_file
    @attachable = VersionedAttachable.new(:name => "Section, No File", 
      :attachment_section => @section)
    
    attachable_count = VersionedAttachable.count
    
    assert !@attachable.save
    
    assert_equal attachable_count, VersionedAttachable.count
    assert_equal @section, @attachable.attachment_section
    assert_equal @section.id, @attachable.attachment_section_id
    assert_nil @attachable.attachment_file_path
  end  
  
  def test_create_with_an_attachment_file_but_no_attachment_section
    @attachable = VersionedAttachable.new(:name => "File Name, No File", 
      :attachment_file_path => "whatever.jpg")
    
    attachable_count = VersionedAttachable.count
    
    assert !@attachable.save

    assert_equal attachable_count, VersionedAttachable.count
    assert_nil @attachable.attachment_section
    assert_nil @attachable.attachment_section_id
    assert_equal "whatever.jpg", @attachable.attachment_file_path
  end  
  
  def test_create_screwy_attachment_file_name
    @attachable = VersionedAttachable.new(:name => "Section ID, File and File Name", 
      :attachment_section_id => @section.id, 
      :attachment_file => @file, 
      :attachment_file_path => "Broken? Yes & No!.txt")
    
    attachable_count = VersionedAttachable.count
    
    assert @attachable.save

    assert_incremented attachable_count, VersionedAttachable.count
    assert_equal "/Broken_Yes_-_No.txt", @attachable.attachment_file_path
  end  
  
  def test_updating_the_attachment_file_name
    @attachable = VersionedAttachable.create!(:name => "Foo", 
      :attachment_section_id => @section.id, 
      :attachment_file => @file, 
      :attachment_file_path => "test.jpg")
    reset(:attachable)

    attachment_count = Attachment.count
    attachment_version = @attachable.attachment_version
    attachment_version_count = Attachment::Version.count
    
    assert @attachable.update_attributes(:attachment_file_path => "test2.jpg", :publish_on_save => true)
    
    assert_equal attachment_count, Attachment.count
    assert_incremented attachment_version, @attachable.attachment_version
    assert_incremented attachment_version_count, Attachment::Version.count
    assert_equal "/test2.jpg", @attachable.attachment_file_path
    
    reset(:attachable)

    assert_equal attachment_count, Attachment.count
    assert_incremented attachment_version, @attachable.attachment_version
    assert_incremented attachment_version_count, Attachment::Version.count
    assert_equal "/test2.jpg", @attachable.attachment_file_path
  end  
  
  def test_updating_the_attachment_file
    @attachable = VersionedAttachable.create!(:name => "Foo", 
      :attachment_section_id => @section.id, 
      :attachment_file => @file, 
      :attachment_file_path => "test.jpg")

    reset(:attachable)

    @file2 = file_upload_object(:original_filename => "foo.txt",
      :content_type => "image/jpeg", :rewind => true,
      :size => "99", :read => "Foo v2")        

    attachment_count = Attachment.count
    attachment_version = @attachable.attachment_version
    attachment_version_count = Attachment::Version.count

    assert @attachable.update_attributes(:attachment_file => @file2)

    assert_equal attachment_count, Attachment.count
    assert_equal attachment_version, @attachable.reload.attachment_version
    assert_incremented attachment_version_count, Attachment::Version.count
    @file.rewind
    assert_equal @file.read, open(@attachable.attachment.full_file_location){|f| f.read}
    
    reset(:attachable)
    @file.rewind
    @file2.rewind

    assert_equal @file.read, open(@attachable.attachment.as_of_version(1).full_file_location){|f| f.read}
    assert_equal @file2.read, open(@attachable.attachment.as_of_version(2).full_file_location){|f| f.read}
    
  end
  
  protected
    def assert_was_saved_properly
      attachable_count = VersionedAttachable.count

      assert @attachable.save

      assert_incremented attachable_count, VersionedAttachable.count
      assert_equal @section, @attachable.attachment_section
      assert_equal @section.id, @attachable.attachment_section_id
      assert_equal "/test.jpg", @attachable.attachment_file_path

      reset(:attachable)

      assert_equal @section, @attachable.attachment_section
      assert_equal @section.id, @attachable.attachment_section_id
      assert_equal "/test.jpg", @attachable.attachment_file_path      
    end
  
end

class VersionedAttachableTest < ActiveSupport::TestCase
  def setup
    #file is a mock of the object that Rails wraps file uploads in
    @file = file_upload_object(:original_filename => "foo.jpg",
      :content_type => "image/jpeg", :rewind => true,
      :size => "99", :read => "01010010101010101")

    @section = Factory(:section, :name => "attachables", :parent => root_section)    
    
    @attachable = VersionedAttachable.create!(:name => "Foo v1", 
      :attachment_section_id => @section.id, 
      :attachment_file => @file, 
      :attachment_file_path => "test.jpg")
    reset(:attachable)
  end

  def test_updating_the_versioned_attachable
    attachment_count = Attachment.count
    attachment_version = @attachable.attachment_version
    attachment_version_count = Attachment::Version.count
    
    assert @attachable.update_attributes(:name => "Foo v2")
    
    assert_equal attachment_count, Attachment.count
    assert_equal attachment_version, @attachable.attachment_version
    assert_equal attachment_version_count, Attachment::Version.count
    assert_equal "Foo v2", @attachable.name
    assert_equal @attachable.as_of_version(1).attachment, @attachable.as_of_version(2).attachment
  end
  
  def test_updating_the_versioned_attachable_attachment_file_path
    attachable_count = VersionedAttachable.count
    attachment_count = Attachment.count
    attachment_version = @attachable.attachment_version
    attachment_version_count = Attachment::Version.count

    assert @attachable.update_attributes(:attachment_file_path => "test2.jpg")

    assert_equal attachable_count, VersionedAttachable.count
    assert_equal attachment_count, Attachment.count
    assert_incremented attachment_version, @attachable.attachment_version
    assert_incremented attachment_version_count, Attachment::Version.count
    assert_equal "/test2.jpg", @attachable.attachment_file_path

    assert_equal @attachable.as_of_version(1).attachment, @attachable.as_of_version(2).attachment
    assert_not_equal @attachable.as_of_version(1).attachment_version, @attachable.as_of_version(2).attachment_version
    assert_equal "/test.jpg", @attachable.as_of_version(1).attachment_file_path
    assert_equal "/test2.jpg", @attachable.as_of_version(2).attachment_file_path
  end  
  
  def test_updating_the_versioned_attachable_attachment_file
    @file2 = file_upload_object(:original_filename => "foo.txt",
      :content_type => "image/jpeg", :rewind => true,
      :size => "99", :read => "Foo v2")

    attachable_count = VersionedAttachable.count
    attachment_count = Attachment.count
    attachment_version = @attachable.attachment_version
    attachment_version_count = Attachment::Version.count

    assert @attachable.update_attributes(:attachment_file => @file2)

    assert_equal attachable_count, VersionedAttachable.count
    assert_equal attachment_count, Attachment.count
    assert_incremented attachment_version, @attachable.attachment_version
    assert_incremented attachment_version_count, Attachment::Version.count

    @file2.rewind
    assert_equal @file2.read, open(@attachable.attachment.full_file_location){|f| f.read}
    
    @file.rewind
    assert_equal @file.read, open(@attachable.attachment.as_of_version(1).full_file_location){|f| f.read}
    
    @file2.rewind
    assert_equal @file2.read, open(@attachable.attachment.as_of_version(2).full_file_location){|f| f.read}
  end
  
end

