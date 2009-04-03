module Cms
  module ErrorHandling
    def self.included(controller)
      controller.class_eval do
          rescue_from Exception, :with => :handle_server_error
      end
    end
    
    def handle_server_error(exception)
      logger.error "Handling Exception: #{exception}"
      render :layout => 'cms/application', 
        :template => 'cms/shared/error', 
        :status => :internal_server_error,
        :locals => {:exception => exception}
    end

  end
end