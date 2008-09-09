class Cms::PortletsController < Cms::ResourceController
  
  layout 'cms/content_library'  
  
  def new
    if params[:portlet_type_id]
      @portlet_type = PortletType.find(params[:portlet_type_id])
      @portlet = @portlet_type.portlets.build
    else
      render :template => 'cms/portlets/select_portlet_type'
    end
  end
      
  def resource_name
    @portlet_type ? @portlet_type.underscore : controller_name
  end
  
  def variable_name
    "portlet"
  end
  
  def index_url
    cms_url :portlets
  end
  
  def show_url
    cms_url :portlets
  end
  
end