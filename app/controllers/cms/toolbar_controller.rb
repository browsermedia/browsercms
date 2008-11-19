class Cms::ToolbarController < Cms::BaseController

  def index
    @mode = params[:mode]
    @page = Page.find(params[:page_id]).as_of_version(params[:page_version])
    render :inline => "<%= cms_toolbar(:sitemap) %>", :layout => 'cms/toolbar'
  end  
  
end