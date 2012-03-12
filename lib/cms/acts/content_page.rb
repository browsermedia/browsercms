#
# Can be included into Controllers in your project to allow them to act as though they are CMS pages.
# This means they can be:
#
#   1. Marked as having requiring permission as though they were in a particular section.
#   2. Handle errors thrown from within the methods in the same way that CMS Pages do.
#   3. Use CMS page templates as layouts (like TemplateSupport)
#
# This is intend to replace and deprecate TemplateSupport (which will be supported for a while for backwards compatibility)
#
# Minor Issue:
#   Error handling for Page not found behaves slightly differently than ContentController currently. If the user is logged
#   in as an editor, they will get a 500 page rather than 404. This would require reworking how the error processing
#   works in Cms::ContentRenderingSupport. 
module Cms
  module Acts

    module PageHelper

      # By default, the Name of the controller (minus 'Controller' will be the page name.)
      # Unless @page_title is set in the controller action
      def page_title(title=nil)
        if title
          @page_title = title
        end
        return controller.class.name.gsub("Controller", "").titleize unless @page_title
        @page_title
      end


      # Do not show the toolbar on Acts::As::ContentPages
      def cms_toolbar
        ""
      end
    end
    module ContentPage

      def self.included(base)
        base.send :include, Cms::ContentRenderingSupport
        base.send :include, Cms::Authentication::Controller
        base.extend ClassMethods

        base.helper Cms::PageHelper
        base.helper Cms::RenderingHelper
        base.helper Cms::MenuHelper
        base.helper Cms::Acts::PageHelper
      end

      # Allows a Controller method to set a page title for an action.
      def page_title=(title)
        @page_title = title
      end

      # Before filter that determines if the current user can access a specific section.
      def check_access_to_section
        user = current_user
        logger.warn "Checking that current_user '#{user.login}' has access to view section with path '#{self.class.in_section}'."
        unless user.able_to_view?(self.class.in_section)
          store_location
          raise Cms::Errors::AccessDenied
        end
      end

      module ClassMethods

        # Requires that some or all of the actions on this controller require the same permissions as a specific section of the website.
        # Note that section paths aren't currently unique so the 'first' section found will be looked at.
        #
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

        def in_section
          @section_path
        end
      end
    end

  end
end
