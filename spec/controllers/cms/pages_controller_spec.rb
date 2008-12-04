require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::PagesController do
  include Cms::PathHelper
  integrate_views
  
  describe "creating a new page" do
    before do
      login_as_user
      @section = root_section
      get :new, :section_id => @section.id
    end
    it "should be a success" do
      response.should be_success
    end
  end
  
  
  describe "publishing a page" do
    before do
      login_as_user
      @page = create_page(:section => root_section, :name => "Test", :path => "test")
      @action = lambda { put :publish, :id => @page.to_param }
    end
    it "should change the status of the page to PUBLISHED" do
      @action.call
      @page.reload.should be_published
    end
    it "should set the flash message" do
      @action.call
      flash[:notice].should  == "Page 'Test' was published"        
    end
    it "should redirect to the page_" do
      @action.call
      response.should redirect_to(@page.path)
    end
    it "should publish all blocks on the page" do
      @block = create_html_block(:name => 'foo')
      @page.create_connector(@block, 'main')
      @action.call
      @block.reload.should be_published
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
  
  describe "reverting" do
    before do
      login_as_user
      @page = create_page(:section => root_section, :name => "V1", :path => "/test")
      @page.update_attributes(:name => "V2")
      @page.update_attributes(:name => "V3")      
      @action = lambda { reset(:page); put :revert_to, :id => @page.to_param, :version => 1; reset(:page) }
    end
    it "should revert to version 1" do
      @action.call
      @page.name.should == "V1"
      @page.version.should == 4
    end
    it "should redirect to the page" do
      @action.call
      response.should redirect_to(@page.path)
    end
    it "should update the status" do
      @action.call
      @page.should_not be_published
    end
  end
  
end