require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::UsersControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    @user = Factory.build(:user)
    @user.groups = [groups(:group_3)]
    @user.save!
    login_as(@user)
  end
  
  def test_show_self
    get :show, :id => @user.id
    assert_response :success
  end
  
  def test_show_other
    get :show, :id => Factory(:user).id
    assert @response.body.include?("Cms::Errors::AccessDenied")
  end
  
  def test_change_password_self
    get :change_password, :id => @user.id
    assert_response :success
  end
  
  def test_change_password_other
    get :change_password, :id => Factory(:user).id
    assert @response.body.include?("Cms::Errors::AccessDenied")
  end
  
  def test_update_password_self
    put :update_password, :id => @user.id,
        :user => {:password => "something_else", :password_confirmation => "something_else"}
    assert_redirected_to cms_user_path(@user)
  end
  
  def test_update_password_other
    put :update_password, :id => Factory(:user).id
    assert @response.body.include?("Cms::Errors::AccessDenied")
  end
end
