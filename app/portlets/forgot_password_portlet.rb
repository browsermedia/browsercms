class ForgotPasswordPortlet < Portlet
  require 'digest/sha1'  

  enable_template_editor true

  def render
    flash[:forgot_password] = {}

    return unless request.method == :post
    user = User.find_by_email(params[:email])
    
    unless user
      flash[:forgot_password][:error] = "We were unable to verify your account. Please make sure your email address is accurate."
      return
    end
    
    user.reset_token = generate_reset_token
    if user.save
      flash[:forgot_password][:notice] = "Your password has been sent to #{params[:email]}"
      ForgotPasswordMailer.deliver_reset_password(self.reset_password_url + '?token=' + user.reset_token, user.email)
    end
  end

  private
  def generate_reset_token
    Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
  end

end
