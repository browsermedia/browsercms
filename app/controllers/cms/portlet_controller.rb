module Cms
  class PortletController < Cms::ApplicationController

    skip_before_filter :redirect_to_cms_site
    skip_before_filter :login_required

    def execute_handler
      @portlet = Portlet.find(params[:id])
      @portlet.controller = self

      method = params[:handler]
      if @portlet.class.superclass.method_defined?(method) or @portlet.class.private_method_defined?(method) or @portlet.class.protected_method_defined?(method)
        raise Cms::Errors::AccessDenied
      else
        redirect_to @portlet.send(method)
      end

    end

  end
end

