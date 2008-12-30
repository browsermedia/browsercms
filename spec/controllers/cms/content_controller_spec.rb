require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::ContentController do
  include Cms::PathHelper
  integrate_views
  
  describe "showing" do
    describe "the home page" do
      it "should display the page with a title" do
        login_as nil        
        @page_template = create_page_template(:file_name => "application")
        @page = create_page(:section => root_section, :path => "/", :name => "Test Homepage", :template => @page_template, :publish_on_save => true)
        get :show, :path => []
        response.should have_tag("title", "Test Homepage")
      end
    end
    describe "the about page" do
      it "should display the page with a title" do
        login_as nil
        @page_template = create_page_template(:file_name => "application")
        @page = create_page(:section => root_section, :path => "/about", :name => "Test About", :template => @page_template, :publish_on_save => true)
        get :show, :path => ["about"]
        response.should have_tag("title", "Test About")
      end
    end
    describe "a protected page" do
      before do
        login_as nil        
        create_system_pages
        @page_template = create_page_template(:file_name => "application")
        @protected_section = create_section(:parent => root_section)
        @page = create_page(:section => @protected_section, :path => "/secret", :name => "Shhh... It's a Secret", :template => @page_template, :publish_on_save => true)
      end
      it "should raise an error if the user is a guest" do
        # In the combo of Rails 2.2 and RSpec, you can't check that
        lambda { get :show, :path => ["secret"] }.should raise_error("Access Denied")
        # response.should have_tag("title", "Access Denied")
        # response.code.should == "403"
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
    describe "an archived page" do
      before do
        login_as nil        
        create_system_pages
        @page_template = create_page_template(:file_name => "application")
        @page = create_page(:section => root_section, :path => "/archived", :name => "Archived", :archived => true, :template => @page_template, :publish_on_save => true)
        @getting_an_archived_page = lambda { get :show, :path => ["archived"] }        
      end
      it "should raise an error" do
        @getting_an_archived_page.should raise_error("No page at '/archived'")
        #response.should have_tag("title", "Not Found")        
      end
      describe "as a logged in user" do
        before { login_as_user } 
        it "should not raise an error" do
          @getting_an_archived_page.call
          response.should have_tag("title", "Archived")
        end        
      end
    end
    describe "a file" do
      before do
        login_as nil
        create_system_pages
        @file = mock_file(:read => "This is a test")
        @file_block = create_file_block(:attachment_section => root_section, :attachment_file => @file, :attachment_file_name => "/test.txt", :publish_on_save => true)
        @action = lambda { get :show, :path => ["test.txt"] }
        @path_to_file = "#{Cms.public_cache.cache_path}/test.txt"
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
      describe "that has been archived" do
        it "should not be able to be found" do
          @file_block.update_attributes(:archived => true)
          reset(:file_block)
          @file_block.attachment.should be_archived
          @action.should raise_error("No page at '/test.txt'")
          # response.should have_tag("title", "Not Found") 
          # response.code.should == "404"
        end
      end
    end
    describe "a protected file" do
      before do
        login_as nil
        create_system_pages
        @protected_section = create_section(:parent => root_section)
        @secret_group = create_group(:name => "Secret")
        @secret_group.sections << @protected_section
        @privileged_user = create_user(:login => "privileged")
        @privileged_user.groups << @secret_group
                
        @file = mock_file(:read => "This is a test")
        @file_block = create_file_block(:attachment_section => @protected_section, :attachment_file => @file, :attachment_file_name => "/test.txt", :publish_on_save => true)
        @action = lambda { get :show, :path => ["test.txt"] }
        @path_to_file = "#{ActionController::Base.cache_store.cache_path}/test.txt"
      end
      describe "when viewed by a guest user" do
        it "should raise an error" do 
          @action.should raise_error("Access Denied")
          #response.should have_tag("title", "Access Denied" )
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
    describe "a search bot" do
      before do
        login_as nil
        create_system_pages
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
        #response.should have_tag("title", "Access Denied")
      end
    end    
  end
  
end