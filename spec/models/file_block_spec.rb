require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileBlock do
  
  describe "when saving a new record" do
    describe "without a file" do
      before do
        @file_block = new_file_block(:file_name => "/test.jpg", :section => root_section)
      end
      it "should raise an error" do
        @file_block.should_not be_valid
        @file_block.errors.on(:file).should == "You must upload a file"
      end
    end
    
    describe "with a file" do
      before(:each) do
        #@file is a mock of the object that Rails wraps file uploads in
        @file = mock("file", :original_filename => "foo.jpg",
          :content_type => "image/jpeg", :rewind => true,
          :size => "99", :read => "01010010101010101")
        @file_block = new_file_block(:file => @file, :section => root_section, :file_name => "/test.jpg", :publish_on_save => true)
      end
      
      describe "without a file_name" do
        it "should add an error" do
          @file_block.file_name = nil
          @file_block.should_not be_valid
          @file_block.errors.on(:file_name).should == "can't be blank"
        end
      end
      
      describe "without a leading / in the file_name" do
        before do
          @file_block.file_name = "test.jpg"
        end
        it "should prepend a /" do
          @file_block.save!
          @file_block.path.should == "/test.jpg"
        end
      end      
      
      it "should create an Attachment" do
        @file_block.save!
        @file_block.attachment.should_not be_nil
        @file_block.attachment.file_type.should == "image/jpeg"
      end

      it "should set the file_name of the attachment" do
        @file_block.save!
        @file_block.path.should == "/test.jpg"
      end

      it "should set the attachment_version" do
        @file_block.save!
        @file_block.attachment_version.should == 1
      end

      it "should set the section correctly" do
        @file_block.save!
        @file_block.attachment.section.should == root_section
      end

      it "should set the section correctly using section_id param" do
        @file_block.save!
        reset(:file_block)
        @file_block.attachment.section.should == root_section
      end

      it "should write out the file" do
        @file_block.save!
        file = File.join(ActionController::Base.cache_store.cache_path, "test.jpg")
        File.exists?(file).should be_true
        open(file){|f| f.read}.should == @file.read
      end      
    end
  end

  describe "when updating an existing record" do
    before do
      @file_block = create_file_block(:section => root_section, :file_name => "/test.jpg", :file => mock_file(:read => "original"), :name => "Test", :updated_by_user => admin_user, :publish_on_save => true)
      reset(:file_block)
      @attachment = @file_block.attachment
    end
    describe "with changes to the attachment's file name" do
      before do
        log FileBlock.to_table_without(:created_at, :updated_at)
        @update_file_block = lambda { @file_block.update_attributes!(:updated_by_user => admin_user, :file_name => "test_new.jpg", :file => nil, :publish_on_save => true) }        
      end
      it "should create a new attachment version" do
        @update_file_block.should change(Attachment::Version, :count).by(1)
      end
      it "should not create a new attachment file" do
        @update_file_block.should_not change(AttachmentFile, :count)
      end
      it "should change the attachment version by 1" do
        @attachment.version == 1
        @update_file_block.call
        @attachment.version.should == 2
      end
    end
    describe "with changes to the attachment's section" do
      before do
        @section = create_section(:parent => root_section, :name => "New")
        @updating_the_file_block = lambda { @file_block.update_attributes!(:section => @section, :updated_by_user => admin_user, :publish_on_save => true) }
      end
      it "should not create a new attachment version" do
        @updating_the_file_block.should_not change(Attachment::Version, :count)
      end
      it "should not change the file block's version " do
        @updating_the_file_block.should_not change(@file_block, :version)
      end
      it "should not change the number of attachment_file records" do
        @updating_the_file_block.should_not change(AttachmentFile, :count)
      end
      it "should change the section" do
        @updating_the_file_block.call
        reset(:file_block)
        @file_block.section.should == @section
      end
      it "should set the file metadata name" do
        @updating_the_file_block.call
        @file_block.attachment.file_name.should == "/test.jpg"
      end
    end
    describe "with changes to the attachment's file data" do
      before do
        @updating_the_file_block = lambda { @file_block.update_attributes!(:file => mock_file(:read => "new"), :updated_by_user => admin_user) }
      end
      it "should not change the number of attachments" do
        @updating_the_file_block.should_not change(Attachment, :count)
      end
      it "should change the number of attachment versions" do
        @updating_the_file_block.should change(Attachment::Version, :count).by(1)
      end
      it "should change the file block version" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should change the data" do
        @updating_the_file_block.call
        reset(:file_block)
        @file_block.attachment.data.should == "new"
      end
      it "should not write out the new file (because the attachment isn't published)" do
        @updating_the_file_block.call
        file = File.join(ActionController::Base.cache_store.cache_path, "test.jpg")
        File.exists?(file).should be_true
        open(file){|f| f.read}.should == "original"
      end      
      it "should not be published" do
        @updating_the_file_block.call
        @file_block.should_not be_published
      end
      it "should not publish the attachment" do
        @updating_the_file_block.call
        @file_block.attachment.should_not be_published
      end
    end
    describe "with changes to the attachment's file data and publish on save" do
      before do
        @updating_the_file_block = lambda { @file_block.update_attributes!(:file => mock_file(:read => "new"), :updated_by_user => admin_user, :publish_on_save => true) }
      end
      it "should not change the number of attachments" do
        @updating_the_file_block.should_not change(Attachment, :count)
      end
      it "should change the number of attachment versions" do
        @updating_the_file_block.should change(Attachment::Version, :count).by(1)
      end
      it "should change the file block version" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should change the data" do
        @updating_the_file_block.call
        reset(:file_block)
        @file_block.attachment.data.should == "new"
      end
      it "should not write out the new file" do
        @updating_the_file_block.call
        file = File.join(ActionController::Base.cache_store.cache_path, "test.jpg")
        File.exists?(file).should be_true
        open(file){|f| f.read}.should == "new"
      end      
      it "should be published" do
        @updating_the_file_block.call
        @file_block.should be_published
      end
      it "should publish the attachment" do
        @updating_the_file_block.call
        @file_block.attachment.should be_published
      end
    end
    describe "without changes to the attachment" do
      before do
        @updating_the_file_block = lambda { @file_block.update_attributes!(:name => "Test 2", :updated_by_user => admin_user, :publish_on_save => true) }
      end
      it "should not create a new attachment" do
        @updating_the_file_block.should_not change(Attachment, :count)
      end
      it "should not create a new attachment version" do
        @updating_the_file_block.should_not change(Attachment::Version, :count)
      end
      it "should change the file block's version by 1" do
        @updating_the_file_block.should change(@file_block, :version).by(1)
      end
      it "should change the file block" do
        @updating_the_file_block.call
        @file_block.name.should == "Test 2"
      end
    end
  end

  describe "when viewing an older version of a file block" do
    before do
      @file1 = mock_file(:content_type => "text/plain", :read => "v1")      
      @file2 = mock_file(:content_type => "text/plain", :read => "v2")
      @file_block = create_file_block(:file => @file1, :file_name => "/test.txt", :section => root_section, :updated_by_user => admin_user)
      @file_block.update_attributes(:file => @file2, :updated_by_user => admin_user)
      reset(:file_block)            
    end
    it "should show the correct content" do
      @file_block.as_of_version(1).attachment.data.should == "v1"
    end
  end

  describe "when archiving a file block" do
    it "should archive the attachment" do
      pending
    end
  end

  describe "when deleting a file block" do
    it "should delete the attachment" do
      pending
    end
  end

end
