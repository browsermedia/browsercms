require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::UsersController do
  controller_setup

  before(:each) do
    @user = create_user
  end
  describe "index" do
    before(:each) do
      @action = lambda { get :index }
    end
    it "should be success" do
      @action.call
      response.should be_success
    end
    it "should list all users" do
      @action.call
      response.should have_tag("span[class=?]", "username", "#{@user.login}")
    end
  end

  describe "new" do
    before(:each) do
      @action = lambda {get :new }
    end

    it "should be success" do
      @action.call
      response.should be_success
    end
    it "should have form elements for user fields" do
      @action.call
      response.should have_tag("input#user_login")
      response.should have_tag("input#user_first_name")
      response.should have_tag("input#user_last_name")
      response.should have_tag("input#user_email")
      response.should have_tag("input#user_password")
      response.should have_tag("input#user_password_confirmation")
    end
    describe "with groups" do
      before do
        @group = create_group
      end
      it "should list all groups as checkboxes" do
        @action.call
        response.should have_tag("label[for=?]", "groups")
        response.should have_tag("input[type=?][value=?]", "checkbox", @group.id)
      end
    end
  end

  describe "create" do
    before(:each) do
      @new_user = new_user
      @action = lambda { post :create, :user => @new_user.attributes.merge({:password=>"123456", :password_confirmation=>"123456"})}
    end
    it "should not fail (sending browser back to 'New User' page)" do
      @action.call
      response.should_not have_tag("h2", "New User")
    end
    it "should be redirect" do
      @action.call
      response.should be_redirect
    end

    it "should redirect to index" do
      @action.call
      response.should redirect_to(:action => "index")
    end
    it "should add a user to the database" do
      @action.should change(User, :count).by(1)
    end
    
    describe "with groups" do
      before do
        @group = create_group
        @action = lambda { post :create, :group_ids => [@group.id], :user => @new_user.attributes.merge({:password=>"123456", :password_confirmation=>"123456"})}
        
      end
      it "should set the group on the user" do
        @action.call
        user = User.last
        user.groups.count.should == 1
        user.groups.first.should == @group
      end
    end
  end

  describe "edit" do
    before(:each) do
      @user = create_user
      @action = lambda { get :edit, :id => @user.id}
    end
    it "should be success" do
      @action.call
      response.should be_success
    end
    it "should show edit form without password fields" do
      @action.call
      response.should have_tag("input#user_login")
      response.should have_tag("input#user_first_name")
      response.should have_tag("input#user_last_name")
      response.should have_tag("input#user_email")
      response.should_not have_tag("input#user_password")
      response.should_not have_tag("input#user_password_confirmation")
    end
  end

  describe "update" do
    before(:each) do
      @user = create_user
      @action = lambda { put :update, :id => @user.id, :user => { :first_name => "First"} }
    end
    it "should be redirect" do
      @action.call
      response.should be_redirect
    end
    it "should redirect to index" do
      @action.call
      response.should redirect_to(:action => "index")
    end
    it "should not add a user to the database" do
      @action.should change(User, :count).by(0)
    end

    it "should update the user's name" do
      @action.call
      u = User.find(@user.id)
      u.first_name.should == "First"
    end
  end

  describe "change_password" do
    before(:each) do
      @user = create_user
      @action = lambda { get :change_password, :id => @user.id }
    end

    it "should be success" do
      @action.call
      response.should be_success
    end
    it "should show form with just password fields" do
      @action.call
      response.should_not have_tag("input#user_login")
      response.should_not have_tag("input#user_first_name")
      response.should_not have_tag("input#user_last_name")
      response.should_not have_tag("input#user_email")
      response.should have_tag("input#user_password")
      response.should have_tag("input#user_password_confirmation")
    end
  end

  describe "update password" do
    before(:each) do
      @user = create_user
    end

    describe "on failure" do
      before do
        @action = lambda { put :update, :id => @user.id, :on_fail_action => "change_password",
            :user => {:password => "will_fail_validation", :confirm_password => "something_else"} }
      end
      it "should not redirect" do
        @action.call
        response.should_not be_redirect
        response.should be_success
      end
      it "should display change_password" do
        @action.call
        response.should have_tag("h2", "Set New Password")
      end
    end
    describe "while dealing w/ groups" do
      before do
        @group = create_group
        @user.groups << @group
        @action = lambda { put :update, :id => @user.id, :on_fail_action => "change_password",
            :user => {:password => "password", :confirm_password => "password"} }
      end
      it "should not remove the existing groups" do
        @action.call
        user = User.find(@user.id)
        user.groups.count.should == 1        
      end
    end
  end
  
  describe "add to groups" do
    before(:each) do
      @user = create_user
      @groups = [create_group.id, create_group.id]
      @action = lambda { put :update, :id => @user.id, :group_ids => @groups }
    end
    it "should be redirect" do
      @action.call
      response.should be_redirect
    end
    it "should change group membership" do
      @action.call
      @user.groups.count.should == 2 
    end
  end
end