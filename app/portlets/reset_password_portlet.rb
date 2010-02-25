class ResetPasswordPortlet < Portlet

  def render
    flash[:reset_password] = {}
    
    unless params[:token]
      flash[:reset_password][:error] = I18n.t("portlets.reset_password.no_token")
      return
    end

    @user = User.find_by_reset_token(params[:token])

    unless @user
      flash[:reset_password][:notice] = I18n.t("portlets.reset_password.invalid_token")   
      return
    end

    if request.method == :post
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      
      if @user.save
        flash[:reset_password][:notice] = I18n.t("portlets.reset_password.reset")
      end
    end
  end

end
