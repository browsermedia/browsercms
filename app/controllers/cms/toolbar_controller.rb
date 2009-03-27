class Cms::ToolbarController < Cms::BaseController

  def index
    if params[:page_toolbar] != "0"
      @mode = params[:mode]
      @page_toolbar_enabled = true
    end
    @page_version = params[:page_version]    
    @page = Page.find(params[:page_id]).as_of_version(params[:page_version])
  end  
  
end
