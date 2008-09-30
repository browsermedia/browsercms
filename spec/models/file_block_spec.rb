require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileBlock do
  
  describe "when saving a new record" do
    before(:each) do
      #@file is a mock of the object that Rails wraps file uploads in
        @file = mock("file", :original_filename => "test.jpg",
          :content_type => "image/jpeg", :rewind => true,
          :size => "99", :read => "01010010101010101")
    end

    it "should create FileMetadata when passed a rails file object" do
      f = create_file_block(:file => @file, :section => root_section)
      f.file_metadata.should_not be_nil
      f.file_metadata.file_type.should == "image/jpeg"
    end

    it "should use / when in the root section" do
      f = create_file_block(:file => @file, :section => root_section)
      f.path.should == "/#{f.file_metadata.id}_test.jpg"
    end

    it "should file path should include section name" do
      s = create_section(:path => "/section_name")
      f = create_file_block(:file => @file, :section => s)

      #Need to make sure section transient attribute is cleared
      f = FileBlock.find(f.id)
      f.path.should == "/section_name/#{f.file_metadata.id}_test.jpg"

    end

    it "should set the section correctly" do
      f = create_file_block(:file => @file, :section => root_section)
      f.file_metadata.section.should == root_section
    end

    it "should look up section based on id" do
      f = FileBlock.new(:section_id => root_section.id)
      f.section.should == root_section
      f.section_id.should == root_section.id
    end

    it "should return correct section id after loading from database" do
      f = create_file_block(:file => @file, :section_id => root_section.id)
      f = FileBlock.find(f.id)
      f.section_id.should == root_section.id
      f.section.should == root_section
    end

    it "should set the section correctly using section_id param" do
      f = create_file_block(:file => @file, :section_id => root_section.id)
      f = FileBlock.find(f.id)
      f.file_metadata.section.should == root_section
    end

    #Yes, this test was actually failing at one point
    it "should set the updated_at" do
      f = create_file_block(:file => @file, :section_id => root_section.id)
      f = FileBlock.find(f.id)
      f.updated_at.should_not be_nil      
    end

    it "should write out the file" do
      f = create_file_block(:file => @file, :section => root_section)
      file = File.join(ActionController::Base.cache_store.cache_path, "#{f.file_metadata_id}_test.jpg")
      File.exists?(file).should be_true
      open(file){|f| f.read}.should == @file.read
    end
  end

  describe "when updating an existing record" do
    before do
      @file_block = create_file_block(:section => root_section, :file => mock_file, :name => "Test")
      @file_block = FileBlock.find(@file_block.id)
    end
    describe "with changes to the file metadata's section" do
      before do
        @section = create_section(:parent => root_section, :name => "New")
        @updating_the_file_block = lambda { @file_block.update_attribute(:section_id, @section.id) }
      end
      it "should create a new file metadata" do
        @updating_the_file_block.should change(FileMetadata, :count).by(1)
      end
      it "should change the file block's version by 1" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should not change the number of file_binary_data records" do
        @updating_the_file_block.should_not change(FileBinaryData, :count)
      end
      it "should change the section" do
        @updating_the_file_block.call
        @file_block = FileBlock.find(@file_block.id)
        @file_block.section.should == @section
      end
    end
    describe "with changes to the file metadata's file data" do
      before do
        @section = create_section(:parent => root_section, :name => "New")
        @updating_the_file_block = lambda { @file_block.update_attribute(:file, mock_file(:read => "foo")) }
      end
      it "should create a new file metadata" do
        @updating_the_file_block.should change(FileMetadata, :count).by(1)
      end
      it "should change the file block's version by 1" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should change the number of file_binary_data records by 1" do
        @updating_the_file_block.should change(FileBinaryData, :count).by(1)
      end
      it "should change the data" do
        @updating_the_file_block.call
        @file_block = FileBlock.find(@file_block.id)
        @file_block.file_metadata.data.should == "foo"
      end
    end
    describe "without changes to the file metadata" do
      before do
        @updating_the_file_block = lambda { @file_block.update_attribute(:name, "Test 2") }
      end
      it "should not create a new file metadata" do
        @updating_the_file_block.should_not change(FileMetadata, :count)
      end
      it "should change the file block's version by 1" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should change the file block" do
        @updating_the_file_block.call
        @file_block = FileBlock.find(@file_block.id)
        @file_block.name.should == "Test 2"
      end
    end
  end

end
