require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::LinksController do
  include Cms::PathHelper
  integrate_views
  
  describe "creating a new link" do
    before do
      login_as_user
      @section = root_section
      @action = lambda { post :create, :link => { :name => "Test", :url => "http://www.example.com" }, :section_id => @section.id }
    end
    it "should respond with success" do
      get :new, :section_id => @section.id
      response.should be_success
    end
    it "should be a redirect" do
      @action.call 
      response.should be_redirect
    end
    it "should increase the number of links" do
      @action.should change(Link, :count).by(1)
    end
  end

  describe "editing a link" do
    before do
      login_as_user
      @section = root_section
      @link = create_link
      @action = lambda { put :update, :link => { :name => "Test Updated", :url => "http://www.updated-example.com" }, :id => @link.id }
    end
    it "should respond with success" do
      get :edit, :id => @link.id
      response.should be_success
    end
    it "should be a redirect" do
      @action.call
      response.should be_redirect
    end
    it "should change the values" do
      @action.call
      Link.first.name.should == "Test Updated"
      Link.first.url.should == "http://www.updated-example.com"
    end
  end

end