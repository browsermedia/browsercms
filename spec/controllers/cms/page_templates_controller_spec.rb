require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::PageTemplatesController do
  integrate_views
  include Cms::PathHelper
  
  before { login_as_user }

  describe "get page templates" do
    before { get :index }
    it_should_assign(:page_templates)
    it_should_render(:index)
    it_should_be_successful
  end

  describe "get new page template form" do
    before { get :new }
    it_should_assign(:page_template)
    it_should_render(:new)
    it_should_be_successful
  end
  
  describe "create new page template" do
    before do
      @page_template = new_page_template(:name => "Test")
      PageTemplate.stub!(:new).and_return(@page_template)
      @page_template.stub!(:save).and_return(true)        
    end
    def do_post
      post :create, :page_template => @page_template.attributes        
    end
    describe "with valid attributes" do
      it "should load the attributes from the form" do
        PageTemplate.should_receive(:new).with(@page_template.attributes).and_return(@page_template)
        do_post
      end
      it "should save the page template" do
        @page_template.should_receive(:save).and_return(true)
        do_post
      end
      it "should set the flash message" do
        do_post
        flash[:notice].should == "Page Template 'Test' was created"
      end
      it "should redirect to the page templates url" do
        do_post
        response.should redirect_to(cms_url(:page_templates))
      end
    end
    describe "with invalid attributes" do
      before do
        @page_template.stub!(:save).and_return(false)
      end
      it "should render the new template" do
        do_post
        response.should render_template(:new)
      end
    end
  end
  
  describe "get edit page template form" do
    before do 
      @page_template = create_page_template
      get :edit, :id => @page_template.id 
    end
    it "should assign the page template" do
      assigns[:page_template].should == @page_template
    end
    it_should_render(:edit)
    it_should_be_successful    
  end
  
  describe "update page template" do
    before do
      @page_template = new_page_template(:name => "Test")
      @page_template.stub!(:id).and_return(7)
      PageTemplate.stub!(:find).and_return(@page_template)
      @page_template.stub!(:update_attributes).and_return(true)        
    end
    def do_put
      put :update, :id => @page_template.id, :page_template => @page_template.attributes
    end
    describe "with valid attributes" do
      it "should find the page template" do
        PageTemplate.should_receive(:find).with("7").and_return(@page_template)
        do_put
      end
      it "should update the attributes from the form" do
        @page_template.should_receive(:update_attributes).with(@page_template.attributes).and_return(true)
        do_put
      end
      it "should set the flash message" do
        do_put
        flash[:notice].should == "Page Template 'Test' was updated"
      end
      it "should redirect to the page templates url" do
        do_put
        response.should redirect_to(cms_url(:page_templates))
      end
    end
    describe "with invalid attributes" do
      before do
        @page_template.stub!(:update_attributes).and_return(false)
      end
      it "should render the new template" do
        do_put
        response.should render_template(:edit)
      end
    end
  end  
  
  describe "destroy page template" do
    before do
      @page_template = new_page_template(:name => "Test")
      @page_template.stub!(:id).and_return(7)
      PageTemplate.stub!(:find).and_return(@page_template)
      @page_template.stub!(:destroy).and_return(true)        
    end
    def do_delete
      delete :destroy, :id => @page_template.id
    end    
    it "should find the page template" do
      PageTemplate.should_receive(:find).with("7").and_return(@page_template)
      do_delete      
    end
    it "should destroy the page template" do
      @page_template.should_receive(:destroy).and_return(true)
      do_delete      
    end
    it "should set the flash message" do
      do_delete
      flash[:notice].should == "Page Template 'Test' was deleted"
    end    
    it "should redirect to the page templates url" do
      do_delete
      response.should redirect_to(cms_url(:page_templates))      
    end
  end
  
end