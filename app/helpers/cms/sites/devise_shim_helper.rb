module Cms
  module Sites

    # A shim that can be added to Portlet helpers to provide Devise behavior.
    module DeviseShimHelper

      # Shim to ensure main_app. is available for this helper.
      def main_app
        Rails.application.class.routes.url_helpers
      end

      include DeviseHelper

      # Use public routes (/login) for paths
      include Cms::Sites::AuthenticationHelper


      def resource
        :cms_user
      end

      def resource_name
        :cms_user
      end

      def devise_mapping
        @devise_mapping ||= Devise.mappings[:cms_user]
      end
    end
  end
end
