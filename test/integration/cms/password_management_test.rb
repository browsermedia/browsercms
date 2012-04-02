require 'test_helper'

class PasswordManagementTest < ActionController::IntegrationTest

  def setup
    given_there_is_a_cmsadmin
    given_there_is_a_guest_group
    given_there_is_a_sitemap
    @group = FactoryGirl.create(:group, :name => "Member")

    @section = FactoryGirl.create(:public_section, :parent => root_section, :name => "Passwords", :path => "/passwords")
    @section.save

    @user = FactoryGirl.create(:user, :email => "dexter@miamidade.gov")
    @user.groups << @group
    @user.save!

    @forgot_password_page = FactoryGirl.create(:page, :section => @section, :name => "Forgot password", :path => "/passwords")
    @reset_password_page = FactoryGirl.create(:page, :section => @section, :name => "Reset password", :path => "/passwords/reset")

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

  def test_forgot_password_will_send_email
    get "/passwords"
    assert_response :success
    
    post "/passwords", :email => Cms::User.last.email
    assert_response :success
    assert flash[:forgot_password][:notice]
    assert ActionMailer::Base.deliveries.empty?
  end

  def forgot_password_should_render_a_form_with_an_email_address_to_enter
    get "/passwords"
    puts @response.body
    assert_select 'input#email'
    assert_response :success
  end

  def test_reset_password
    test_forgot_password_will_send_email
    token = Cms::User.last.reset_token
    get "/passwords/reset?token=#{token}"
    assert_response :success
    
    post "/passwords/reset", :token => token
    assert_response :success
    assert flash[:reset_password][:notice]
  end

end
