require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Attachment do
  
  describe "an existing record" do
    before do
      @attachment = create_attachment(:section => root_section, :file => mock_file)
    end
    describe "in the root section" do
      it "should be able to be found by path with a leading /" do
        Attachment.find_by_path("/#{@attachment.file_name}").should == @attachment
      end
      it "should be able to be found by path without a leading /" do
        Attachment.find_by_path(@attachment.file_name).should == @attachment
      end
    end
    describe "in a sub section" do
      before do
        @sub_section = create_section(:parent => root_section, :path => "/sub")
        @attachment.update_attribute(:section, @sub_section)
      end
      it "should be able to be found by path with a leading slash" do
        Attachment.find_by_path("/sub/#{@attachment.file_name}").should == @attachment
      end
      it "should be able to be found by path without a leading slash" do
        Attachment.find_by_path("sub/#{@attachment.file_name}").should == @attachment
      end
    end    
  end  
  
  describe "when saving with a file" do
    before do
      #@file is a mock of the object that Rails wraps file uploads in
      @file = mock_file
        
      @saving_the_cms_file = lambda {@attachment = Attachment.create!(:file => @file, :section => root_section) }
    end
    it "should set the file_name" do
      @saving_the_cms_file.call
      @attachment.file_name.should == "#{@attachment.id}_test.jpg"
    end
    it "should set the file_extension" do
      @saving_the_cms_file.call
      @attachment.file_extension.should == "jpg"
    end
    it "should create the file_datum" do
      @saving_the_cms_file.call
      @attachment.data.should == "01010010101010101"
    end
    it "should set the file_type" do
      @saving_the_cms_file.call
      @attachment.file_type.should == "image/jpeg"
    end
    it "should set the file_size" do
      @saving_the_cms_file.call
      @attachment.file_size.should == 99
    end
    it "should increate Attachment count by 1" do
      @saving_the_cms_file.should change(Attachment, :count).by(1)
    end
    it "should increate AttachmentFile count by 1" do
      @saving_the_cms_file.should change(AttachmentFile, :count).by(1)
    end
    it "should return the icon that matches it's extension" do
      @saving_the_cms_file.call
      @attachment.icon.should == :gif
    end
    it "should return the icon 'file' if the extension is unknown" do
      Attachment.new(:file_extension => "xyz").icon.should == :file
    end
    it "should return the icon 'file' if the extension is nil" do
      Attachment.new.icon.should == :file
    end
    it "should write out the file" do
      @saving_the_cms_file.call
      file = File.join(ActionController::Base.cache_store.cache_path, "#{@attachment.id}_test.jpg")
      File.exists?(file).should be_true
      open(file){|f| f.read}.should == @file.read
    end
    it "should write out the file to a sub-drectory, creating it if necessary" do
      root_section.update_attribute :path, "/test"
      @saving_the_cms_file.call
      file = File.join(ActionController::Base.cache_store.cache_path, "test", "#{@attachment.id}_test.jpg")
      File.exists?(file).should be_true
      open(file){|f| f.read}.should == @file.read
    end
    
  end
  
end
