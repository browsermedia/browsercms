require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileMetadata do
  
  describe "an existing record" do
    before do
      @file_metadata = create_file_metadata(:section => root_section, :file => mock_file)
    end
    describe "in the root section" do
      it "should be able to be found by path with a leading /" do
        FileMetadata.find_by_path("/#{@file_metadata.file_name}").should == @file_metadata
      end
      it "should be able to be found by path without a leading /" do
        FileMetadata.find_by_path(@file_metadata.file_name).should == @file_metadata
      end
    end
    describe "in a sub section" do
      before do
        @sub_section = create_section(:parent => root_section, :path => "/sub")
        @file_metadata.update_attribute(:section, @sub_section)
      end
      it "should be able to be found by path with a leading slash" do
        FileMetadata.find_by_path("/sub/#{@file_metadata.file_name}").should == @file_metadata
      end
      it "should be able to be found by path without a leading slash" do
        FileMetadata.find_by_path("sub/#{@file_metadata.file_name}").should == @file_metadata
      end
    end    
  end  
  
  describe "when saving with a file" do
    before do
      #@file is a mock of the object that Rails wraps file uploads in
      @file = mock_file
        
      @saving_the_cms_file = lambda {@file_metadata = FileMetadata.create!(:file => @file, :section => root_section) }
    end
    it "should set the file_name" do
      @saving_the_cms_file.call
      @file_metadata.file_name.should == "#{@file_metadata.id}_test.jpg"
    end
    it "should set the file_extension" do
      @saving_the_cms_file.call
      @file_metadata.file_extension.should == "jpg"
    end
    it "should create the file_datum" do
      @saving_the_cms_file.call
      @file_metadata.data.should == "01010010101010101"
    end
    it "should set the file_type" do
      @saving_the_cms_file.call
      @file_metadata.file_type.should == "image/jpeg"
    end
    it "should set the file_size" do
      @saving_the_cms_file.call
      @file_metadata.file_size.should == 99
    end
    it "should increate FileMetadata count by 1" do
      @saving_the_cms_file.should change(FileMetadata, :count).by(1)
    end
    it "should increate FileBinaryData count by 1" do
      @saving_the_cms_file.should change(FileBinaryData, :count).by(1)
    end
    it "should return the icon that matches it's extension" do
      @saving_the_cms_file.call
      @file_metadata.icon.should == :gif
    end
    it "should return the icon 'file' if the extension is unknown" do
      FileMetadata.new(:file_extension => "xyz").icon.should == :file
    end
    it "should return the icon 'file' if the extension is nil" do
      FileMetadata.new.icon.should == :file
    end
    it "should write out the file" do
      @saving_the_cms_file.call
      file = File.join(ActionController::Base.cache_store.cache_path, "#{@file_metadata.id}_test.jpg")
      File.exists?(file).should be_true
      open(file){|f| f.read}.should == @file.read
    end
    it "should write out the file to a sub-drectory, creating it if necessary" do
      root_section.update_attribute :path, "/test"
      @saving_the_cms_file.call
      file = File.join(ActionController::Base.cache_store.cache_path, "test", "#{@file_metadata.id}_test.jpg")
      File.exists?(file).should be_true
      open(file){|f| f.read}.should == @file.read
    end
    
  end
  
end
