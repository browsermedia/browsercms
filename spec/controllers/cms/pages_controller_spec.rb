require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::PagesController do
  include Cms::PathHelper
  integrate_views
  
  describe "show" do
    before do
      #@file = create_file_block(:file => )
      @action = lambda { get :show, :path => ['/test.txt'] }
    end
    describe "a file that has not been written to the cache dir" do
      it "should write out the file" do 
        pending
      end
      it "should return a 200" do 
        pending
      end
      it "return the contents of the file" do 
        pending
      end
    end
    describe "a file that has been written to the cache dir" do
      before do
        open("#{ActionController::Base.cache_store.cache_path}/test.txt", "w") do |f|
          f << "Foo"
        end
      end
      it "should not overrite the file" do 
        pending
      end
      it "should return a 200" do 
        @action.call
        response.should be_success
      end
      it "return the contents of the file" do 
        @action.call
      
        @streamer = response.body
        @streamer.class.should == Proc
        
        @output = mock("output")
        @output.should_receive(:write).with("Foo")
              
        @streamer.call(response, @output)
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