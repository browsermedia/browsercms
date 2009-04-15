class Cms::PageRoutesController < Cms::BaseController
  
  before_filter :load_page_route, :only => [:show, :edit, :update, :destroy]
  
  def index
    @page_routes = Page.all(:order => "name")
  end
  
  def new
    
  end
  
  def show
    redirect_to edit_cms_page_route
  end
  
  def destroy
    
  end
  
end