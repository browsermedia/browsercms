require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::PagesController do
  include Cms::PathHelper
  integrate_views
  
  describe "showing" do
    describe "the home page" do
      it "should display the page with a title" do
        @page_template = create_page_template(:file_name => "application")
        @page = create_page(:path => "/", :name => "Test Homepage", :template => @page_template)
        get :show, :path => []
        response.should have_tag("title", "Test Homepage")
      end
    end
    describe "a file" do
      before do
        @file = mock_file(:original_filename => "test.txt", :read => "This is a test")
        @file_block = create_file_block(:section => root_section, :file => @file)
        @action = lambda { get :show, :path => ["#{@file_block.file_metadata_id}_test.txt"] }
        @path_to_file = "#{ActionController::Base.cache_store.cache_path}/#{@file_block.file_metadata_id}_test.txt"
      end
      describe "that has not been written to the cache dir" do
        before do
          File.delete(@path_to_file) if File.exists?(@path_to_file)
        end
        it "should write out the file" do 
          @action.call
          File.exists?(@path_to_file).should be_true
        end
        it "return the contents of the file" do 
          @action.call
          streaming_file_contents(response).should == "This is a test"
        end
        it "should set the content type properly" do
          @action.call
          response.content_type.should == "text/plain"
        end
      end
      describe "that has been written to the cache dir" do
        before do
          open(@path_to_file, "w") {|f| f << "Don't Overwrite Me!"}
        end
        it "return the contents of the file" do 
          @action.call
          streaming_file_contents(response).should == "Don't Overwrite Me!"
        end      
      end
    end
  end
  
  describe "moving a page" do
    describe "with a valid section id" do
      before do
        login_as_user
        @from_section = create_section(:name => "From", :parent => root_section)
        @to_section = create_section(:name => "To", :parent => root_section)
        @page = create_page(:section => @from_section, :name => "Mover")
        @action = lambda { put :move_to, :id => @page.to_param, :section_id => @to_section.to_param }
      end
      it "should change the section_id of the page to the new section's id" do
        @action.call
        @page.reload.section_id.should == @to_section.id
      end
      it "should set the flash message" do
        @action.call
        flash[:notice].should  == "Page 'Mover' was moved to 'To'."        
      end
      it "should redirect to the section with page_id" do
        @action.call
        response.should redirect_to(cms_url(@to_section, :page_id => @page.to_param))
      end
    end
  end
  
  describe "revisions" do
    before do
      login_as_user
      @page = create_page(:section => root_section, :name => "V1")
      @page.update_attribute(:name, "V2")
      @page.update_attribute(:name, "V3")
      @action = lambda { get :revisions, :id => @page.to_param }
    end
    it "should have links to view each version" do
      @action.call
      (1..3).each do |n|
        response.should have_tag("a[href=?]", cms_path(@page, :show_version, :version => n), "v.#{n}")
      end
    end
  end
  
end