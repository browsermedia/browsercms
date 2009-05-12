require File.join(File.dirname(__FILE__), '/../../test_helper')

class FileBlockTest < ActiveSupport::TestCase
  def setup
    #@file is a mock of the object that Rails wraps file uploads in
    @file = file_upload_object(:original_filename => "foo.jpg",
      :content_type => "image/jpeg", :rewind => true,
      :size => "99", :read => "01010010101010101")
    @file_block = Factory.build(:file_block, :attachment_file => @file, :attachment_section => root_section, :attachment_file_path => "/test.jpg", :publish_on_save => true)
  end
  
  def test_attachment_is_required
    @file_block.attachment_file = nil
    assert !@file_block.valid?
    assert_equal "You must upload a file", @file_block.errors.on(:attachment_file)
  end
  
  def test_attachment_file_path_is_required
    @file_block.attachment_file_path = nil
    assert !@file_block.valid?
    assert_equal "File Name is required for attachment", @file_block.errors.on(:attachment_file_path)
  end
  
  def test_no_leading_slash_in_file_path
    @file_block.attachment_file_path = "test.jpg"
    assert @file_block.save
    assert_equal "/test.jpg", @file_block.path
  end
  
  def test_create_attachment
    assert @file_block.save
    assert !@file_block.attachment.nil?
    assert "image/jpeg", @file_block.attachment.file_type
    assert_equal "/test.jpg", @file_block.path
    assert_equal 1, @file_block.attachment_version
    assert_equal root_section, @file_block.attachment.section
  end
  
  def test_reverting
    assert @file_block.save
    assert "/test.jpg", @file_block.attachment_file_path
    assert "01010010101010101", File.read(@file_block.attachment.full_file_location)
    
    attachment_id = @file_block.attachment_id
    new_file = file_upload_object(:original_filename => "foo.jpg",
      :content_type => "image/jpeg", :rewind => true,
      :size => "99", :read => "10100101010101010")
    
    @file_block.update_attributes(:attachment_file => new_file, :publish_on_save => true)
    reset(:file_block)
    
    assert @file_block.save
    assert 2, @file_block.version
    assert attachment_id, @file_block.attachment_id
    assert 2, @file_block.attachment_version    
    assert "/test.jpg", @file_block.attachment_file_path
    assert "10100101010101010", File.read(@file_block.attachment.full_file_location)
    
    @file_block.revert_to(1)
    reset(:file_block)

    assert 2, @file_block.version
    assert 3, @file_block.draft.version
    assert attachment_id, @file_block.attachment_id
    assert 2, @file_block.attachment_version
    assert 3, @file_block.draft.attachment_version
    assert "/test.jpg", @file_block.attachment_file_path
    assert "01010010101010101", File.read(@file_block.attachment.full_file_location)
    assert "10100101010101010", File.read(@file_block.as_of_draft_version.attachment.full_file_location)
    
  end
  
end

class UpdatingFileBlockTest < ActiveSupport::TestCase
  def setup
    @file_block = Factory(:file_block,
      :attachment_section => root_section,
      :attachment_file_path => "/test.jpg",
      :attachment_file => mock_file(:read => "original"),
      :name => "Test",
      :publish_on_save => true)
    reset(:file_block)
    @attachment = @file_block.attachment
  end
  
  def test_change_attachment_file_name
    attachment_version = @attachment.version
    file_attachment_version = @file_block.attachment_version
    attachment_version_count = Attachment::Version.count
    
    assert @file_block.update_attributes(
      :attachment_file_path => "test_new.jpg",
      :attachment_file => nil,
      :publish_on_save => true)
    
    assert_incremented attachment_version, @attachment.reload.version
    assert_incremented file_attachment_version, @file_block.attachment_version
    assert_incremented attachment_version_count, Attachment::Version.count
  end  
  
  def test_change_attachment_section
    attachment_version_count = Attachment::Version.count
    file_block_version = @file_block.version

    @section = Factory(:section, :parent => root_section, :name => "New")
    @file_block.update_attributes!(:attachment_section => @section, :publish_on_save => true)

    assert_incremented attachment_version_count, Attachment::Version.count
    assert_incremented file_block_version, @file_block.reload.version
    assert_equal @section, @file_block.attachment_section
    assert_equal "/test.jpg", @file_block.attachment.file_path
    assert_equal "test.jpg", @file_block.attachment.file_name
  end  
  
  def test_change_attachment_data_with_save
    attachment_count = Attachment.count
    attachment_version_count = Attachment::Version.count
    file_block_version = @file_block.draft.version

    @section = Factory(:section, :parent => root_section, :name => "New")
    @file_block.update_attributes!(:attachment_file => mock_file(:read => "new"))
    
    assert_equal attachment_count, Attachment.count
    assert_incremented attachment_version_count, Attachment::Version.count
    assert_incremented file_block_version, @file_block.draft.version
    assert_equal "new", open(@file_block.as_of_draft_version.attachment.full_file_location){|f| f.read}
    assert !@file_block.live?
    assert !@file_block.attachment.live?
  end
  
  def test_change_attachment_data_with_save_and_publish
    attachment_count = Attachment.count
    attachment_version_count = Attachment::Version.count
    file_block_version = @file_block.version

    @section = Factory(:section, :parent => root_section, :name => "New")
    @file_block.update_attributes!(:attachment_file => mock_file(:read => "new"), :publish_on_save => true)
    
    assert_equal attachment_count, Attachment.count
    assert_incremented attachment_version_count, Attachment::Version.count
    assert_incremented file_block_version, @file_block.reload.version
    assert_equal "new", open(@file_block.attachment.full_file_location){|f| f.read}
    assert @file_block.published?
    assert @file_block.attachment.published?
  end
  
  def test_no_changes_to_the_attachment
    attachment_count = Attachment.count
    attachment_version_count = Attachment::Version.count
    file_block_version = @file_block.version
    
    @file_block.update_attributes!(:name => "Test 2", :publish_on_save => true)
    
    assert_equal attachment_count, Attachment.count
    assert_equal attachment_version_count, Attachment::Version.count
    assert_incremented file_block_version, @file_block.reload.version
    assert_equal "Test 2", @file_block.name
  end
  
end

class ViewingOlderVersionOfFileTest < ActiveSupport::TestCase
  
  def test_that_it_shows_the_correct_content
    @file1 = mock_file(:content_type => "text/plain", :read => "v1")      
    @file2 = mock_file(:content_type => "text/plain", :read => "v2")
    @file_block = Factory(:file_block, :attachment_file => @file1, :attachment_file_path => "/test.txt", :attachment_section => root_section)
    @file_block.update_attributes(:attachment_file => @file2)
    #reset(:file_block)            
    assert_equal "v1", open(@file_block.as_of_version(1).attachment.full_file_location){|f| f.read}
  end
  
end

class ExistingFileBlockTest < ActiveSupport::TestCase
  def setup
    @file_block = Factory(:file_block, :attachment_file => mock_file, :attachment_file_path => "/test.txt", :attachment_section => root_section)
  end
  
  def test_archiving
    assert @file_block.update_attributes(:archived => true)
    assert @file_block.attachment.archived?
  end
  
  def test_destroy
    @file_block.destroy      
    assert_nil Attachment.find_live_by_file_path("/test.txt")
  end
end

class ExistingFileBlocksTest < ActiveSupport::TestCase
  def setup
    @one = Factory(:file_block, :attachment_file => mock_file, :attachment_file_path => "/one.txt", :attachment_section => root_section)
    @two = Factory(:file_block, :attachment_file => mock_file, :attachment_file_path => "/two.txt", :attachment_section => root_section)
    @section = Factory(:section, :name => "A")
    @a1 = Factory(:file_block, :attachment_file => mock_file, :attachment_file_path => "/a/1.txt", :attachment_section => @section)
    @a2 = Factory(:file_block, :attachment_file => mock_file, :attachment_file_path => "/2.txt", :attachment_section => @section)
    #reset(:one, :two, :a1, :a2)
  end
  
  def test_find_blocks_in_root_section
    assert_equal [@one, @two], FileBlock.by_section(root_section).all(:order => "file_blocks.id")
  end
  
  def test_find_blocks_in_sub_section
    assert_equal [@a1, @a2], FileBlock.by_section(@section).all(:order => "file_blocks.id")
  end
end


