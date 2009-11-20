#
# Can be included into Controllers in your project to allow them to act as though they are CMS pages.
# This means they can be:
#
#   1. Marked as being in a particular section, which will make them use the same security rules as that section.
#   2. Handle errors thrown from within the methods in the same way that CMS Pages do.


module Cms
  module Acts
    module ContentPage

      def self.included(base)
        base.send :include, Cms::ContentRenderingSupport
        base.send :include, Cms::Authentication::Controller
        base.extend ClassMethods
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

        # Sets which section this Controller should pretend that it's in. Should match the 'path' attribute for a given section.
        def place_in_section(path, options={})
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
