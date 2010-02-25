class Cms::PageRoutesController < Cms::BaseController
  
  before_filter :load_page_route, :only => [:show, :edit, :update, :destroy]
  layout 'cms/administration'
  
  def index
    @page_routes = PageRoute.paginate(:order => "name", :page => params[:page])
  end
  
  def new
    @page_route = PageRoute.new
  end
  
  def create
    @page_route = PageRoute.new(params[:page_route])
    if @page_route.save
      flash[:notice] = I18n.t("controllers.page_routes.created")
      redirect_to cms_page_route_url(@page_route)
    else
      render :action => "new"
    end
  end
  
  def update
    if @page_route.update_attributes(params[:page_route])
      flash[:notice] = I18n.t("controllers.page_routes.updated")
      redirect_to cms_page_route_url(@page_route)
    else
      render :action => "new"
    end
    
  end
  
  def destroy
    @page_route.destroy
    flash[:notice] = I18n.t("controllers.page_routes.deleted")
    redirect_to cms_page_routes_url
  end
  
  protected
    def load_page_route
      @page_route = PageRoute.find(params[:id])
    end
  
end