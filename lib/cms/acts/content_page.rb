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
      end
    end
  end
end
