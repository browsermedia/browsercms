require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileMetadata do
  
  describe "when saving with a file" do
    before do
      #@file is a mock of the object that Rails wraps file uploads in
      @file = mock("file", :original_filename => "test.jpg", 
        :content_type => "image/jpeg", :rewind => true,
        :size => "99", :read => "01010010101010101")
        
      @saving_the_cms_file = lambda {@cms_file = FileMetadata.create(:file => @file) }
    end
    it "should set the file_name" do
      @saving_the_cms_file.call
      @cms_file.file_name.should == "test.jpg"
    end
    it "should set the file_extension" do
      @saving_the_cms_file.call
      @cms_file.file_extension.should == "jpg"
    end
    it "should create the file_datum" do
      @saving_the_cms_file.call
      @cms_file.data.should == "01010010101010101"
    end
    it "should set the file_type" do
      @saving_the_cms_file.call
      @cms_file.file_type.should == "image/jpeg"
    end
    it "should set the file_size" do
      @saving_the_cms_file.call
      @cms_file.file_size.should == 99
    end
    it "should increate FileMetadata count by 1" do
      @saving_the_cms_file.should change(FileMetadata, :count).by(1)
    end
    it "should increate FileBinaryData count by 1" do
      @saving_the_cms_file.should change(FileBinaryData, :count).by(1)
    end
    it "should return the icon that matches it's extension" do
      @saving_the_cms_file.call
      @cms_file.icon.should == :gif
    end
    it "should return the icon 'file' if the extension is unknown" do
      FileMetadata.new(:file_extension => "xyz").icon.should == :file
    end
    it "should return the icon 'file' if the extension is nil" do
      FileMetadata.new.icon.should == :file
    end
  end
  
end
