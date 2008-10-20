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

    describe "by keyword" do
      before(:each) do
        @user_with_email = create_user(:email => "somekid@southpark.com")
        @user_with_name = create_user(:first_name => "Stan", :last_name => "Marsh")
        @user_with_login = create_user(:login => "mylogin")
      end
      it "should find users by email" do
        action = lambda { get :index, :key_word => "somekid" }
        action.call
        response.should     have_tag("span[class=?]", "username", "#{@user_with_email.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_name.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_login.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user.login}")
      end
      it "should find users by login" do
        action = lambda { get :index, :key_word => "mylogin" }
        action.call
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_email.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_name.login}")
        response.should     have_tag("span[class=?]", "username", "#{@user_with_login.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user.login}")
      end
      it "should find users by first name" do
        action = lambda { get :index, :key_word => "stan" }
        action.call
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_email.login}")
        response.should     have_tag("span[class=?]", "username", "#{@user_with_name.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_login.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user.login}")
      end
      it "should find users by last name" do
        action = lambda { get :index, :key_word => "marsh" }
        action.call
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_email.login}")
        response.should     have_tag("span[class=?]", "username", "#{@user_with_name.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user_with_login.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user.login}")
      end
    end
    describe "with disabled users" do
      before(:each) do
        @disabled_user = new_user
        @disabled_user.disable!
      end

      it "should not list disabled users by default" do
        @action.call
        response.should_not have_tag("span[class=?]", "username", "#{@disabled_user.login}")
      end

      it "should list disabled users if asked for" do
        action = lambda { get :index, :show_expired => "true" }
        action.call
        response.should have_tag("span[class=?]", "username", "#{@disabled_user.login}")
      end
    end

    describe "in groups" do
      before(:each) do
        @not_found = create_user

        @in_group = create_group
        @not_in_group = create_group
        @user.groups << @in_group
      end
      it "should find users in groups" do
        action = lambda { get :index, :group_id => @in_group.id }
        action.call
        response.should     have_tag("span[class=?]", "username", "#{@user.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@not_found.login}")
      end
    end
    describe "with all conditions" do
      before(:each) do
        @disabled_user = new_user(:first_name => "SomethingElse")
        @disabled_user.disable!
        @found_user = create_user(:first_name => "Stan")
        @found_user.disable!
        @new_group = create_group
        @found_user.groups << @new_group
        @found_user.save!
        @live_user = create_user(:first_name => "Stan")
      end
      it "should find disabled users with a keyword and show_expired" do
        action = lambda { get :index, :show_expired => "true", :key_word => "stan" }
        action.call
        response.should_not have_tag("span[class=?]", "username", "#{@disabled_user.login}")
        response.should     have_tag("span[class=?]", "username", "#{@found_user.login}")
        response.should     have_tag("span[class=?]", "username", "#{@live_user.login}")
      end
      it "should find not disabled users with a keyword" do
        action = lambda { get :index, :key_word => "stan" }
        action.call
        response.should_not have_tag("span[class=?]", "username", "#{@disabled_user.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@found_user.login}")
        response.should     have_tag("span[class=?]", "username", "#{@live_user.login}")
      end
      it "should find users only in a group, who are are disabled, by name" do
        action = lambda { get :index, :show_expired => "true", :key_word => "stan", :group_id => @new_group.id }
        action.call
        response.should_not have_tag("span[class=?]", "username", "#{@disabled_user.login}")
        response.should     have_tag("span[class=?]", "username", "#{@found_user.login}")
        response.should     have_tag("option[value=?][selected=?]", "#{@new_group.id}", "selected")
        response.should_not have_tag("span[class=?]", "username", "#{@live_user.login}")        
      end
    end
    describe "pagination" do
      before do
        @user1 = create_user(:first_name => "Adama")
        @user2 = create_user(:first_name => "Adama")
      end
      it "should show all results" do
        action = lambda { get :index, :key_word => "Adama" }
        action.call
        response.should     have_tag("span[class=?]", "username", "#{@user1.login}")
        response.should     have_tag("span[class=?]", "username", "#{@user2.login}")
      end
      it "should show only first result" do
        action = lambda { get :index, :key_word => "Adama", :per_page => 1 }
        action.call
        response.should     have_tag("span[class=?]", "username", "#{@user1.login}")
        response.should_not have_tag("span[class=?]", "username", "#{@user2.login}")
      end
      it "should show only second result" do
        action = lambda { get :index, :key_word => "Adama", :per_page => 1, :page => 2 }
        action.call
        response.should_not have_tag("span[class=?]", "username", "#{@user1.login}")
        response.should     have_tag("span[class=?]", "username", "#{@user2.login}")
      end
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
      response.should have_tag("input#user_expires_at")
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
    it "should update the flash accordingly" do
      @action.call 
      flash[:notice].should == "User '#{@new_user.login}' was created"
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
      response.should have_tag("input#user_expires_at")
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
    it "should set expires_at" do
      action =  lambda { put :update, :id => @user.id, :user => { :expires_at => "1/2/2008" } }
      action.call
      u = User.find(@user.id)
      u.expires_at.month.should == 1
      u.expires_at.day.should == 2
      u.expires_at.year.should == 2008
    end
    
    it "should update the flash accordingly" do
      @action.call 
      flash[:notice].should == "User '#{@user.login}' was updated"
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
      it "should update the flash appropriately" do
        @action.call 
        flash[:notice].should == "Password for '#{@user.login}' changed"
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