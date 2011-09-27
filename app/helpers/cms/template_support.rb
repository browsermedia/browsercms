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
        helper Cms::RenderingHelper
        helper do
          def cms_toolbar
            if current_user.able_to?(:administrate, :edit_content, :publish_content)
              %Q{<iframe src="#{cms.toolbar_path(:page_toolbar => 0)}" width="100%" height="100px" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" name="cms_toolbar"></iframe>}
            end
          end
        end
      end
    end
  end
  
end
