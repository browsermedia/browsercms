require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileBlock do
  
  describe "when saving a new record" do
    before(:each) do
      #@file is a mock of the object that Rails wraps file uploads in
        @file = mock("file", :original_filename => "test.jpg",
          :content_type => "image/jpeg", :rewind => true,
          :size => "99", :read => "01010010101010101")
    end

    it "should create Attachment when passed a rails file object" do
      f = create_file_block(:file => @file, :section => root_section)
      f.attachment.should_not be_nil
      f.attachment.file_type.should == "image/jpeg"
    end

    it "should use / when in the root section" do
      f = create_file_block(:file => @file, :section => root_section)
      f.path.should == "/#{f.attachment.id}_test.jpg"
    end

    it "should file path should include section name" do
      s = create_section(:path => "/section_name")
      f = create_file_block(:file => @file, :section => s)

      #Need to make sure section transient attribute is cleared
      f = FileBlock.find(f.id)
      f.path.should == "/section_name/#{f.attachment.id}_test.jpg"

    end

    it "should set the section correctly" do
      f = create_file_block(:file => @file, :section => root_section)
      f.attachment.section.should == root_section
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
      f.attachment.section.should == root_section
    end

    #Yes, this test was actually failing at one point
    it "should set the updated_at" do
      f = create_file_block(:file => @file, :section_id => root_section.id)
      f = FileBlock.find(f.id)
      f.updated_at.should_not be_nil      
    end

    it "should write out the file" do
      f = create_file_block(:file => @file, :section => root_section)
      file = File.join(ActionController::Base.cache_store.cache_path, "#{f.attachment_id}_test.jpg")
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
        @updating_the_file_block = lambda { @file_block.update_attributes!(:section => @section, :updated_by_user => create_user) }
      end
      it "should create a new file metadata" do
        @updating_the_file_block.should change(Attachment, :count).by(1)
      end
      it "should change the file block's version by 1" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should not change the number of attachment_file records" do
        @updating_the_file_block.should_not change(AttachmentFile, :count)
      end
      it "should change the section" do
        @updating_the_file_block.call
        @file_block = FileBlock.find(@file_block.id)
        @file_block.section.should == @section
      end
      it "should set the file metadata name" do
        @updating_the_file_block.call
        @file_block.attachment.file_name.should =~ /\d*_test.jpg/
      end
    end
    describe "with changes to the file metadata's file data" do
      before do
        @section = create_section(:parent => root_section, :name => "New")
        @updating_the_file_block = lambda { @file_block.update_attribute(:file, mock_file(:read => "foo")) }
      end
      it "should create a new file metadata" do
        @updating_the_file_block.should change(Attachment, :count).by(1)
      end
      it "should change the file block's version by 1" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should change the number of attachment_file records by 1" do
        @updating_the_file_block.should change(AttachmentFile, :count).by(1)
      end
      it "should change the data" do
        @updating_the_file_block.call
        @file_block = FileBlock.find(@file_block.id)
        @file_block.attachment.data.should == "foo"
      end
    end
    describe "without changes to the file metadata" do
      before do
        @updating_the_file_block = lambda { @file_block.update_attribute(:name, "Test 2") }
      end
      it "should not create a new file metadata" do
        @updating_the_file_block.should_not change(Attachment, :count)
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
