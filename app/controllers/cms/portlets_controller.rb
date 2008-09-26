class Cms::PortletsController < Cms::BaseController

  layout 'cms/content_library'

  def new
    @portlet_type = PortletType.find(params[:portlet_type_id])
    @block = @portlet_type.portlets.build
    @content_type = ContentType.find_by_key("portlet")
    render :template => 'cms/blocks/new'
  end

end