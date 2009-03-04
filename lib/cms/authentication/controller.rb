module Cms
  module Authentication
    module Controller
      protected
        # Returns true or false if the user is logged in.
        # Preloads User.current with the user model if they're logged in.
        def logged_in?
          !current_user.nil? && !current_user.guest?
        end

        # Accesses the current user from the session.
        # If the user is not logged in, this will be set to the guest user
        def current_user
          @current_user ||= begin
            User.current = (login_from_session || login_from_cookie || User.guest)  
          end
        end

        # Store the given user id in the session.
        def current_user=(new_user)
          session[:user_id] = new_user ? new_user.id : nil
          @current_user = new_user || false
          @current_user = User.current
        end

        # Check if the user is authorized
        #
        # Override this method in your controllers if you want to restrict access
        # to only a few actions or if you want to check if the user
        # has the correct rights.
        #
        # Example:
        #
        #  # only allow nonbobs
        #  def authorized?
        #    current_user.login != "bob"
        #  end
        #
        def authorized?(action=nil, resource=nil, *args)
          logged_in?
        end

        # Filter method to enforce a login requirement.
        #
        # To require logins for all actions, use this in your controllers:
        #
        #   before_filter :login_required
        #
        # To require logins for specific actions, use this in your controllers:
        #
        #   before_filter :login_required, :only => [ :edit, :update ]
        #
        # To skip this in a subclassed controller:
        #
        #   skip_before_filter :login_required
        #
        def login_required
          authorized? || access_denied
        end

        # Redirect as appropriate when an access request fails.
        #
        # The default action is to redirect to the login screen.
        #
        # Override this method in your controllers if you want to have special
        # behavior in case the user is not authorized
        # to access the requested action.  For example, a popup window might
        # simply close itself.
        def access_denied
          respond_to do |format|
            format.html do
              store_location
              redirect_to cms_login_path
            end
            # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
            # you may want to change format.any to e.g. format.any(:js, :xml)
            # format.any do
            #   request_http_basic_authentication 'Web Password'
            # end
          end
        end

        # Store the URI of the current request in the session.
        #
        # We can return to this location by calling #redirect_back_or_default.
        def store_location
          session[:return_to] = request.request_uri
        end

        # Redirect to the URI stored by the most recent store_location call or
        # to the passed default.  Set an appropriately modified
        #   after_filter :store_location, :only => [:index, :new, :show, :edit]
        # for any controller you want to be bounce-backable.
        def redirect_back_or_default(default)
          redirect_to(session[:return_to] || default)
          session[:return_to] = nil
        end

        # Inclusion hook to make #current_user and #logged_in?
        # available as ActionView helper methods.
        def self.included(base)
          base.send :helper_method, :current_user, :logged_in?, :authorized? if base.respond_to? :helper_method
        end

        #
        # Login
        #

        # Called from #current_user.  First attempt to login by the user id stored in the session.
        def login_from_session
          self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
        end

        # Called from #current_user.  Now, attempt to login by basic authentication information.
        def login_from_basic_auth
          authenticate_with_http_basic do |login, password|
            self.current_user = User.authenticate(login, password)
          end
        end
    
        #
        # Logout
        #

        # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
        # for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
        def login_from_cookie
          user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
          if user && user.remember_token?
            self.current_user = user
            handle_remember_cookie! false # freshen cookie token (keeping date)
            self.current_user
          end
        end

        # This is ususally what you want; resetting the session willy-nilly wreaks
        # havoc with forgery protection, and is only strictly necessary on login.
        # However, **all session state variables should be unset here**.
        def logout_keeping_session!
          # Kill server-side auth cookie
          User.current.forget_me if User.current.is_a? User
          User.current = false     # not logged in, and don't do it for me
          kill_remember_cookie!     # Kill client-side auth cookie
          session[:user_id] = nil   # keeps the session but kill our variable
          # explicitly kill any other session variables you set
        end

        # The session should only be reset at the tail end of a form POST --
        # otherwise the request forgery protection fails. It's only really necessary
        # when you cross quarantine (logged-out to logged-in).
        def logout_killing_session!
          logout_keeping_session!
          reset_session
        end
    
        #
        # Remember_me Tokens
        #
        # Cookies shouldn't be allowed to persist past their freshness date,
        # and they should be changed at each login

        # Cookies shouldn't be allowed to persist past their freshness date,
        # and they should be changed at each login

        def valid_remember_cookie?
          return nil unless User.current
          (User.current.remember_token?) && 
            (cookies[:auth_token] == User.current.remember_token)
        end
    
        # Refresh the cookie auth token if it exists, create it otherwise
        def handle_remember_cookie! new_cookie_flag
          return unless User.current
          case
          when valid_remember_cookie? then User.current.refresh_token # keeping same expiry date
          when new_cookie_flag        then User.current.remember_me 
          else                             User.current.forget_me
          end
          send_remember_cookie!
        end
  
        def kill_remember_cookie!
          cookies.delete :auth_token
        end
    
        def send_remember_cookie!
          cookies[:auth_token] = {
            :value   => User.current.remember_token,
            :expires => User.current.remember_token_expires_at }
        end

    end
  end
end
