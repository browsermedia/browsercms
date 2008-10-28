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
  
  describe "showing" do
    describe "the home page" do
      it "should display the page with a title" do
        @page_template = create_page_template(:file_name => "application")
        @page = create_page(:section => root_section, :path => "/", :name => "Test Homepage", :template => @page_template, :publish_on_save => true)
        get :show, :path => []
        response.should have_tag("title", "Test Homepage")
      end
    end
    describe "the about page" do
      it "should display the page with a title" do
        @page_template = create_page_template(:file_name => "application")
        @page = create_page(:section => root_section, :path => "/about", :name => "Test About", :template => @page_template, :publish_on_save => true)
        get :show, :path => ["about"]
        response.should have_tag("title", "Test About")
      end
    end
    describe "a protected page" do
      before do
        @page_template = create_page_template(:file_name => "application")
        @protected_section = create_section(:parent => root_section)
        @page = create_page(:section => @protected_section, :path => "/secret", :name => "Shhh... It's a Secret", :template => @page_template, :publish_on_save => true)
      end
      it "should raise an error if the user is a guest" do
        lambda { get :show, :path => ["secret"] }.should raise_error      
      end
      it "should show the page if the user has access" do
        @secret_group = create_group(:name => "Secret")
        @secret_group.sections << @protected_section
        @privileged_user = create_user(:login => "privileged")
        @privileged_user.groups << @secret_group
        login_as @privileged_user
        get :show, :path => ["secret"]
        response.should have_tag("title", "Shhh... It's a Secret")
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
    describe "a protected file" do
      before do
        @protected_section = create_section(:parent => root_section)
        @secret_group = create_group(:name => "Secret")
        @secret_group.sections << @protected_section
        @privileged_user = create_user(:login => "privileged")
        @privileged_user.groups << @secret_group
                
        @file = mock_file(:original_filename => "test.txt", :read => "This is a test")
        @file_block = create_file_block(:section => @protected_section, :file => @file)
        @action = lambda { get :show, :path => ["#{@file_block.file_metadata_id}_test.txt"] }
        @path_to_file = "#{ActionController::Base.cache_store.cache_path}/#{@file_block.file_metadata_id}_test.txt"
      end
      describe "when viewed by a guest user" do
        it "should raise an error" do 
          @action.should raise_error("Access Denied")
        end
      end
      describe "when viewed by a privileged user" do
        before do
          login_as @privileged_user
        end
        it "return the contents of the file" do 
          @action.call
          streaming_file_contents(response).should == "This is a test"
        end      
      end
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
      @page.add_content_block!(@block, 'main')
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
      @page.update_attribute(:name, "V2")
      @page.update_attribute(:name, "V3")
      @action = lambda { put :revert_to, :id => @page.to_param, :version => 1 }
    end
    it "should revert to version 1" do
      @action.call
      @page = Page.find(@page.id)
      @page.name.should == "V1"
      @page.version.should == 4
    end
    it "should redirect to the page" do
      @action.call
      response.should redirect_to(@page.path)
    end
    it "should update the status" do
      @action.call
      @page.should be_in_progress
    end
  end
  
  describe "a search bot" do
    before do
      @page_template = create_page_template(:file_name => "application")
      @public_page = create_page(:section => root_section, :path => "/", :name => "Test Homepage", :template => @page_template, :publish_on_save => true)
      root_section.groups << create_group(:code => "search_bot")
      @secret_section = create_section(:parent => root_section)
      @secret_page = create_page(:section => @secret_section, :path => "/secret", :name => "Shhh... It's a Secret", :template => @page_template, :publish_on_save => true) 
      request.stub!(:user_agent).and_return("googlebot") 
    end
    it "should be a guest" do
      current_user.should be_guest
    end
    it "should be a search_bot" do
      current_user.should be_search_bot
    end
    it "should have access to a public page" do
      get :show, :path => []
      response.should have_tag("title", "Test Homepage")
    end
    it "should not have access to a non-public page" do
      lambda { get :show, :path => ["secret"] }.should raise_error("Access Denied")
    end
  end
  
end