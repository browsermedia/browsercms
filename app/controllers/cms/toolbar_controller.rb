class Cms::ToolbarController < Cms::BaseController

  def index
    @mode = params[:mode]
    @page = Page.find(params[:page_id]).as_of_version(params[:page_version])
  end  
  
end