class ResetPasswordPortlet < Cms::Portlet

  def render
    flash[:reset_password] = {}
    
    unless params[:token]
      flash[:reset_password][:error] = "No password token given"
      return
    end

    @user = Cms::User.find_by_reset_token(params[:token])

    unless @user
      flash[:reset_password][:notice] = "Invalid password token"    
      return
    end

    if request.post?
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      
      if @user.save
        flash[:reset_password][:notice] = 'Password has been reset'
      end
    end
  end

end
