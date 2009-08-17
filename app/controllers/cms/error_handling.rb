module Cms
  module ErrorHandling
    def self.included(controller)
      controller.class_eval do
        rescue_from Exception, :with => :handle_server_error unless RAILS_ENV == "test"
        rescue_from Cms::Errors::AccessDenied, :with => :handle_access_denied
      end
    end
    
    def handle_server_error(exception)
      logger.error "Handling Exception: #{exception}"
      render :layout => 'cms/application', 
        :template => 'cms/shared/error', 
        :status => :internal_server_error,
        :locals => {:exception => exception}
    end
    
    def handle_access_denied(exception)
      render :layout   => 'cms/application', 
             :template => 'cms/shared/access_denied',
             :status => 403
    end

  end
end
