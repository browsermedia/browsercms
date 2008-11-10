require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::SectionsController do
  include Cms::PathHelper
  integrate_views

  before { login_as_user }
  
  describe "Editing a section" do
    it "should show the edit form with the name prepopulated" do
      @section = create_section(:parent => root_section)
      group = admin_user.groups.first
      group.sections << @section
      get :edit, :id => @section.to_param
      response.should have_tag("input[name=?][value=?]", "section[name]", @section.name)
    end
  end
  
  describe "Updating a section" do
    before do
      @section = create_section(:name => "V1", :parent => root_section)
      @action = lambda { put :update, :id => @section.to_param, :section => {:name => "V2"} }
    end
    it "should change the properties" do
      @action.call
      @section.reload.name.should == "V2"
    end
    it "should set the flash message" do
      @action.call
      flash[:notice].should == "Section 'V2' was updated"
    end
    it "should redirect to the section in the sitemap" do
      @action.call
      response.should redirect_to(cms_url(@section))
    end
  end
  
  describe "File Browser" do
    describe "for the root section" do
      before do
        @foo = create_section(:parent => root_section, :name => "Foo", :path => '/foo')
        @bar = create_section(:parent => root_section, :name => "Bar", :path => '/bar')
        @home = create_page(:section => root_section, :name => "Home", :path => '/home')
        get :file_browser, :format => :xml, "CurrentFolder" => "/", "Command" => "GetFilesAndFolders", "Type" => "Page"
      end
      it "should return the FCK-specific XML document" do
        response.should have_tag("Connector[command=?][resourceType=?]", "GetFilesAndFolders", "Page") do |connector|
          connector.should have_tag("CurrentFolder[path=?][url=?]", "/", "/")
          connector.should have_tag("Folders") do |folders|
            folders.should have_tag("Folder[name=?]", "Foo")
            folders.should have_tag("Folder[name=?]", "Bar")
          end
          connector.should have_tag("Files") do |files|
            files.should have_tag("File[name=?][url=?][size=?]", "Home", "/home", "?")
          end
        end
      end      
    end
    describe "for a sub section" do
      before do
        @foo = create_section(:parent => root_section, :name => "Foo", :path => '/foo')        
        @bar = create_section(:parent => @foo, :name => "Bar", :path => '/foo/bar')
        @foo_page = create_page(:section => @foo, :name => "Foo Page", :path => '/foo/page')
        @home = create_page(:section => root_section, :name => "Home", :path => '/home')
        get :file_browser, :format => :xml, "CurrentFolder" => "/Foo/", "Command" => "GetFilesAndFolders", "Type" => "Page"
      end
      it "should return the FCK-specific XML document" do
        response.should have_tag("Connector[command=?][resourceType=?]", "GetFilesAndFolders", "Page") do |connector|
          connector.should have_tag("CurrentFolder[path=?][url=?]", "/Foo/", "/Foo/")
          connector.should have_tag("Folders") do |folders|
            folders.should have_tag("Folder[name=?]", "Bar")
          end
          connector.should have_tag("Files") do |files|
            files.should have_tag("File[name=?][url=?][size=?]", "Foo Page", "/foo/page", "?")
          end
        end
      end      
    end
  end
  
end