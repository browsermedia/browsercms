class Cms::ToolbarController < Cms::BaseController

  def index
    set_page_mode
    @page = Page.find(params[:page_id]).as_of_version(params[:page_version])
    render :inline => "<%= cms_toolbar(:sitemap) %>", :layout => 'cms/toolbar'
  end

  private
  def set_page_mode
    @mode = params[:mode] || session[:page_mode] || "edit"
    session[:page_mode] = @mode      
  end
  
  
end