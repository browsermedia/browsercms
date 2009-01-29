# This controller handles the login/logout function of the site.  
class Cms::SessionsController < Cms::BaseController
  
  skip_before_filter :login_required
  layout "cms/login"
  def login
    if request.post?
      logout_keeping_session!
      user = User.authenticate(params[:login], params[:password])
      if user
        # Protects against session fixation attacks, causes request forgery
        # protection if user resubmits an earlier form using back
        # button. Uncomment if you understand the tradeoffs.
        # reset_session
        self.current_user = user
        new_cookie_flag = (params[:remember_me] == "1")
        handle_remember_cookie! new_cookie_flag
        flash[:notice] = "Logged in successfully"
        unless params[:success_url].blank?
          redirect_to params[:success_url]
        else
          redirect_back_or_default(cms_home_url)
        end
      else
        note_failed_signin
        @login       = params[:login]
        @remember_me = params[:remember_me]
        unless params[:failure_url].blank?
          flash[:login_error] = "Log in failed"          
          redirect_to append_to_query_string(params[:failure_url], 
            [:login, params[:login]], 
            [:remember_me, params[:remmember_me]])
        end
      end
    end
  end

  def logout
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(cms_login_url)
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
