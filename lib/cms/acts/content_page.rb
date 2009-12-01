#
# Can be included into Controllers in your project to allow them to act as though they are CMS pages.
# This means they can be:
#
#   1. Marked as being in a particular section, which will make them use the same security rules as that section.
#   2. Handle errors thrown from within the methods in the same way that CMS Pages do.
#
#   Error handling for Page not found behaves slightly differently than ContentController currently. If the user is logged
#   in as an editor, they will get a 500 page rather than 404. This would require reworking how the error processing
#   works in Cms::ContentRenderingSupport. 
module Cms
  module Acts


    module ContentPage

      def self.included(base)
        base.send :include, Cms::ContentRenderingSupport
        base.send :include, Cms::Authentication::Controller
        base.extend ClassMethods

        base.helper Cms::PageHelper
        base.helper Cms::RenderingHelper
        base.helper Cms::MenuHelper
      end

      def check_access_to_section
        user = current_user
        logger.warn "Checking that current_user '#{user.login}' has access to view section with path '#{self.class.in_section}'."
        unless user.able_to_view?(self.class.in_section)
          store_location
          raise Cms::Errors::AccessDenied
        end
      end

      module ClassMethods

        # Sets which section this Controller should pretend that it's in.
        # Params:
        #   path - Should match the 'path' attribute for a given section.
        #   options - Hash of options that will be passed to the before_filter call. See before_filter for valid options.
        #
        # Example:
        #   MyController < ApplicationController
        #     include Cms::Acts::ContentPage
        #     requires_permission_for_section "/somepath", :except=>"action_name"
        #   ...
        #
        def requires_permission_for_section(path, options={})
          logger.warn "Setting path #{path}"
          @section_path = path
          before_filter :check_access_to_section, options
        end

#        def requires_permission()
#
#        end

        def in_section
          @section_path
        end
      end
    end

  end
end
