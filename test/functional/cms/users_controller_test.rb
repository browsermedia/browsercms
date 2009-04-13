require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::UsersControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    login_as_cms_admin
    @user = User.first
    
  end
  
  def test_index
    get :index
    assert_response :success
    assert_select "a", "#{@user.email}"
  end
  
  def test_index_by_email_key_word
    create_key_word_test_users
    get :index, :key_word => "somekid"

    assert_response :success
    assert_select "a", {:count => 1, :text => @user_with_email.email}
    assert_select "a", {:count => 0, :text => @user_with_name.email}
    assert_select "a", {:count => 0, :text => @user_with_login.email}
    assert_select "a", {:count => 0, :text => @user.email}
  end
  
  def test_index_by_login_key_word
    create_key_word_test_users
    get :index, :key_word => "mylogin"

    assert_response :success
    assert_select "a", {:count => 0, :text => @user_with_email.email}
    assert_select "a", {:count => 0, :text => @user_with_name.email}
    assert_select "a", {:count => 1, :text => @user_with_login.email}
    assert_select "a", {:count => 0, :text => @user.email}
  end  
  
  def test_index_by_first_name_key_word
    create_key_word_test_users
    get :index, :key_word => "stan"

    assert_response :success
    assert_select "a", {:count => 0, :text => @user_with_email.email}
    assert_select "a", {:count => 1, :text => @user_with_name.email}
    assert_select "a", {:count => 0, :text => @user_with_login.email}
    assert_select "a", {:count => 0, :text => @user.email}
  end  

  def test_index_by_last_name_key_word
    create_key_word_test_users
    get :index, :key_word => "marsh"

    assert_response :success
    assert_select "a", {:count => 0, :text => @user_with_email.email}
    assert_select "a", {:count => 1, :text => @user_with_name.email}
    assert_select "a", {:count => 0, :text => @user_with_login.email}
    assert_select "a", {:count => 0, :text => @user.email}
  end

  def test_index_with_disabled_users
    @disabled_user = Factory(:user)
    @disabled_user.disable!

    get :index
    assert_response :success
    assert_select "a", {:count => 0, :text => @disabled_user.email}
  end
  
  def test_index_with_show_expired
    @disabled_user = Factory(:user)
    @disabled_user.disable!

    get :index, :show_expired => "true"
    assert_response :success
    assert_select "a", {:count => 1, :text => @disabled_user.email}
  end
  
  def test_index_with_groups
    @not_found = Factory(:user)
    @in_group = Factory(:group)
    @not_in_group = Factory(:group)
    @user.groups << @in_group

    get :index, :group_id => @in_group.id

    assert_response :success
    assert_select "a", {:count => 1, :text => @user.email}
    assert_select "a", {:count => 0, :text => @not_found.email}
  end
  
  def test_new
    @group = Factory(:group)
    
    get :new

    assert_response :success

    assert_select "input#user_login"
    assert_select "input#user_first_name"
    assert_select "input#user_last_name"
    assert_select "input#user_email"
    assert_select "input#user_password"
    assert_select "input#user_expires_at"
    assert_select "input#user_password_confirmation"
    assert_select "input[type=?][value=?]", "checkbox", @group.id
  end
  
  def test_create
    user_count = User.count
    @group = Factory(:group)
    user_params = Factory.attributes_for(:user, :password=>"123456", :password_confirmation=>"123456")
    
    post :create, :user => user_params, :group_ids => [@group.id]
    user = User.find_by_login(user_params[:login])
    
    assert_redirected_to cms_users_path
    assert_incremented user_count, User.count
    assert_equal "User '#{user.login}' was created", flash[:notice]
    assert_equal [@group], user.groups
  end
  
  def test_edit
    get :edit, :id => @user.id
    assert_response :success

    assert_select "input#user_login[value=?]", @user.login
    assert_select "input#user_first_name[value=?]", @user.first_name
    assert_select "input#user_last_name[value=?]", @user.last_name
    assert_select "input#user_email[value=?]", @user.email
    assert_select "input#user_expires_at"
  end
  
  def test_update
    put :update, :id => @user.id, :user => { :first_name => "First"}
    reset(:user)
    
    assert_redirected_to cms_users_path
    assert_equal "First", @user.first_name
    assert_equal "User '#{@user.login}' was updated", flash[:notice]
  end

  def test_change_password
    get :change_password, :id => @user.id

    assert_response :success
    assert_select "input#user_password"
    assert_select "input#user_password_confirmation"
  end
  
  def test_update_password_failure
    put :update_password, :id => @user.id,
      :user => {:password => "will_fail_validation", :password_confirmation => "something_else"}
      
    assert_response :success
    assert_select "h1", "Set New Password"
    assert_select "div#errorExplanation"
  end
  
  def test_update_password_success
    put :update_password, :id => @user.id,
      :user => {:password => "something_else", :password_confirmation => "something_else"}
      
    assert_redirected_to cms_users_path
  end
  
  def test_add_to_groups
    @group_ids = [Factory(:group).id, Factory(:group).id]
    put :update, :id => @user.id, :group_ids => @group_ids
    reset(:user)
    
    assert_redirected_to cms_users_path
    assert_equal 2, @user.groups.count
  end
  
  protected
    def create_key_word_test_users
      @user_with_email = Factory(:user, :email => "somekid@southpark.com")
      @user_with_name = Factory(:user, :first_name => "Stan", :last_name => "Marsh")
      @user_with_login = Factory(:user, :login => "mylogin")
    end
  
end