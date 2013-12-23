#
# Defines the authentication behavior for controllers in BrowserCMS. It can be added to any controller that needs to 
# hook into the BrowserCMS Authentication behavior like so:
#
# class MySuperSecureController < ApplicationController
#   include Cms::Authentication::Controller
#
# 1. Guests - These represents users that are not logged in. What guests can see and do can be modified via the CMS UI. Guests
#             are not considered to be 'logged in'.
# 2. 'Current' User - The currently logged in user is stored in a thread local, and can be accessed anywhere via 'Cms::User.current'.
#             This allows model code to easily record which user is making changes to records, for versioning, etc.
#
# 3. 'Admin' Access Denied Page - If users try to access a protected controller, they are redirected to the CMS administration Login page
#             which may be different than the 'front end' user login page. (Cms::Controller handles that differently)
#
#
# To Dos: It appears as though we are storing the 'current' user in two places, @current_user and Cms::User.current. This is probably not DRY, but
#   more testing would be needed.
#
module Cms
  module Authentication
    module Controller
      # Inclusion hook to make #current_user and #logged_in?
      # available as ActionView helper methods.
      def self.included(base)
        base.send :helper_method, :current_user, :logged_in? if base.respond_to? :helper_method
        base.extend ClassMethods
      end


      module ClassMethods

        # Determines if the current user has at least one of the following permissions. Sets up a before_action that
        # enforces permissions.
        #
        # @param [Symbol, Array<Symbol>] perms One or more permissions.
        # @raise [Cms::Errors::AccessDenied] If the current_user doesn't have ANY of the given permissions.
        #
        # Example:
        # class MyCustomController < Cms::ApplicationController
        #   check_permissions :publish_content, :except => [:index]
        # end
        def check_permissions(*perms)
          opts = Hash === perms.last ? perms.pop : {}
          before_filter(opts) do |controller|
            raise Cms::Errors::AccessDenied unless controller.send(:current_user).able_to?(*perms)
          end
        end
      end

      protected
      # Returns true or false if the user is logged in.
      # Preloads Cms::User.current with the user model if they're logged in.
      def logged_in?
        !current_user.nil? && !current_user.guest?
      end

      # Returns the current user if logged in. If no user is logged in, returns the 'Guest' user which represents a
      # what a visitor can do without being logged in.
      def current_user
        @current_user ||= begin
          Cms::PersistentUser.current = current_cms_user || Cms::User.guest
        end
      end

      # Redirect as appropriate when an access request fails.
      #
      # The default action is to redirect to the BrowserCMS admin login screen.
      #
      # Override this method in your controllers if you want to have special
      # behavior in case the user is not authorized
      # to access the requested action.  For example, a popup window might
      # simply close itself.
      def access_denied
        respond_to do |format|
          format.html do
            store_location
            redirect_to cms.login_path
          end
        end
      end

      # Store the URI of the current request in the session.
      #
      # We can return to this location by calling #redirect_back_or_default.
      def store_location
        session[:return_to] = request.fullpath
      end

      # Redirect to the URI stored by the most recent store_location call or
      # to the passed default.  Set an appropriately modified
      #   after_filter :store_location, :only => [:index, :new, :show, :edit]
      # for any controller you want to be bounce-backable.
      def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end

      # This is ususally what you want; resetting the session willy-nilly wreaks
      # havoc with forgery protection, and is only strictly necessary on login.
      # However, **all session state variables should be unset here**.
      def logout_keeping_session!
        # Kill server-side auth cookie
        Cms::PersistentUser.current.forget_me if Cms::User.current.is_a? User
        Cms::PersistentUser.current = false # not logged in, and don't do it for me
        session[:user_id] = nil # keeps the session but kill our variable
        # explicitly kill any other session variables you set
      end

      # The session should only be reset at the tail end of a form POST --
      # otherwise the request forgery protection fails. It's only really necessary
      # when you cross quarantine (logged-out to logged-in).
      def logout_killing_session!
        logout_keeping_session!
        reset_session
      end

    end
  end
end
