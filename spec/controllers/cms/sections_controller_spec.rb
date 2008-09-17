require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::SectionsController do
  include Cms::PathHelper
  integrate_views

  before { login_as_user }
  
  describe "Editing a section" do
    it "should show the edit form the the name prepopulated" do
      @section = create_section(:parent => root_section)
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
  
end