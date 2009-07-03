# This is a module, not a helper, that is meant to be included
# into controllers that want to use page templates for their layout
module Cms
  module TemplateSupport
    def self.included(controller)
      controller.class_eval do
        include Cms::Authentication::Controller
        include Cms::ErrorHandling
        
        helper Cms::PageHelper
        helper Cms::MenuHelper
        helper do
          def cms_toolbar
            %Q{<iframe src="#{cms_toolbar_path(:page_toolbar => 0)}" width="100%" height="100px" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" name="cms_toolbar"></iframe>}
          end
        end
      end
    end
  end
  
end
