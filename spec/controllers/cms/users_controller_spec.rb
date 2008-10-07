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

    # Test #4 - Fails if user_params in before is inlined. (in IDE)
    # Always fails from command line. Why?
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
      @action = lambda { put :update, :id => @user.id, :on_fail_action => "change_password",
          :user => {:password => "will_fail_validation", :confirm_password => "something_else"} }
    end

    describe "on failure" do
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

  end
end