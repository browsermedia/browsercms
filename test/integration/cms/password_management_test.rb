require File.join(File.dirname(__FILE__) + '/../../test_helper')

class PasswordManagementTest < ActionController::IntegrationTest

  def setup  
    @group = Factory(:group, :name => "Member")

    @section = Factory(:section, :parent => root_section, :name => "Passwords", :path => "/passwords", :allow_groups=>:all)
    @section.save

    @user = Factory(:user, :email => "dexter@miamidade.gov")
    @user.groups << @group
    @user.save!

    @forgot_password_page = Factory(:page, :section => @section, :name => "Forgot password", :path => "/passwords")
    @reset_password_page = Factory(:page, :section => @section, :name => "Reset password", :path => "/passwords/reset")

    @forgot_password_portlet = ForgotPasswordPortlet.create!(:name => "Forgot Password",
                                                             :template => ForgotPasswordPortlet.default_template,
                                                             :connect_to_page_id => @forgot_password_page.id,
                                                             :connect_to_container => "main",
                                                             :publish_on_save => true)

    @reset_password_portlet = ResetPasswordPortlet.create!(:name => "Reset Password",
                                                           :template => ResetPasswordPortlet.default_template,
                                                           :connect_to_page_id => @reset_password_page.id,
                                                           :connect_to_container => "main",
                                                           :publish_on_save => true)

    @forgot_password_page.publish!
    @reset_password_page.publish!
    ActionMailer::Base.deliveries = []
  end

  def test_forgot_password
    get "/passwords"
    assert_response :success
    
    post "/passwords", :email => User.last.email
    assert_response :success    
    assert flash[:forgot_password][:notice]
    assert ActionMailer::Base.deliveries.empty?
  end

  def test_reset_password
    test_forgot_password
    token = User.last.reset_token    
    get "/passwords/reset?token=#{token}"
    assert_response :success
    
    post "/passwords/reset", :token => token
    assert_response :success    
    assert flash[:reset_password][:notice]
  end

end
