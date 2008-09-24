require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileBlock do
  before(:each) do
    #@file is a mock of the object that Rails wraps file uploads in
      @file = mock("file", :original_filename => "test.jpg",
        :content_type => "image/jpeg", :rewind => true,
        :size => "99", :read => "01010010101010101")
  end

  it "should create FileMetadata when passed a rails file object" do
    f = FileBlock.create!(:file => @file, :section => root_section)
    f.file_metadata.should_not be_nil
    f.file_metadata.file_type.should == "image/jpeg"
  end

  it "should use / when in the root section" do
    f = FileBlock.create!(:file => @file, :section => root_section)
    f.path.should == "/#{f.file_metadata.id}_test.jpg"
  end

  it "should file path should include section name" do
    s = create_section(:path => "/section_name")
    f = FileBlock.create!(:file => @file, :section => s)
    
    #Need to make sure section transient attribute is cleared
    f = FileBlock.find(f.id)
    f.path.should == "/section_name/#{f.file_metadata.id}_test.jpg"

  end

  it "should set the section correctly" do
    f = FileBlock.create!(:file => @file, :section => root_section)
    f.file_metadata.section.should == root_section
  end

  it "should look up section based on id" do
    f = FileBlock.new(:section_id => root_section.id)
    f.section.should == root_section
    f.section_id.should == root_section.id
  end
  
  it "should return correct section id after loading from database" do
    f = FileBlock.create!(:file => @file, :section_id => root_section.id)
    f = FileBlock.find(f.id)
    f.section_id.should == root_section.id
    f.section.should be_nil
  end
  
  it "should set the section correctly using section_id param" do
    f = FileBlock.create!(:file => @file, :section_id => root_section.id)
    f.file_metadata.section.should == root_section
  end
  
  it "should write out the file" do
    f = FileBlock.create!(:file => @file, :section => root_section)
    file = File.join(ActionController::Base.cache_store.cache_path, "#{f.file_metadata_id}_test.jpg")
    File.exists?(file).should be_true
    open(file){|f| f.read}.should == @file.read
  end

end
