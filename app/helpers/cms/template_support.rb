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

      end
    end
  end
  
end
