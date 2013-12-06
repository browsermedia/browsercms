module Cms
  module Sites

    # Override Devise Helpers to point to main_app rather than engine.
    # Used for public site authentication.
    module AuthenticationHelper

      def new_session_path(resource_name)
        main_app.new_cms_user_session_path
      end

      def session_path(resource_name)
        main_app.cms_user_session_path
      end

      def password_path(resource_name)
        main_app.cms_user_password_path
      end

      def new_password_path(resource_name)
        main_app.forgot_password_path
      end
    end
  end
end