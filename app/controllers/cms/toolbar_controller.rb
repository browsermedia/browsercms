class Cms::ToolbarController < Cms::BaseController

  def index
    @mode = params[:mode]
    @page_version = params[:page_version]
    @page = Page.find(params[:page_id]).as_of_version(params[:page_version])
  end  
  
end
