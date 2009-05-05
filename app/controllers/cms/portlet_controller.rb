class Cms::PortletController < Cms::ApplicationController
  
  skip_before_filter :redirect_to_cms_site
  skip_before_filter :login_required
  
  def execute_handler
    @portlet = Portlet.find(params[:id])
    @portlet.controller = self
    redirect_to @portlet.send(params[:handler])
  end
    
end