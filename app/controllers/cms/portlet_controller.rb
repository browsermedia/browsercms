module Cms
  class PortletController < Cms::ApplicationController

    skip_before_action :redirect_to_cms_site if self.respond_to?(:redirect_to_cms_site)

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

    # Adding this here temporarily to get tests to pass.  Makes little sense as this is skipping this method
    # but for some reason this method is not defined within the portlet controller.
    def redirect_to_cms_site
      if using_cms_subdomains? && !request_is_for_cms_subdomain?
        redirect_to(url_with_cms_domain_prefix)
      end
    end

  end
end

