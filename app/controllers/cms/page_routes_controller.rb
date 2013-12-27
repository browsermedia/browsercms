module Cms
  class PageRoutesController < Cms::BaseController

    before_filter :load_page_route, :only => [:edit, :update, :destroy]

    def index
      @page_routes = PageRoute.paginate(:page => params[:page]).order("name")
    end

    def new
      @page_route = PageRoute.new
    end

    def create
      @page_route = PageRoute.new(page_route_params)
      if @page_route.save
        flash[:notice] = "Page Route Created"
        redirect_to page_routes_path
      else
        render :action => "new"
      end
    end

    def update
      if @page_route.update(page_route_params)
        flash[:notice] = "Page Route Updated"
        redirect_to page_routes_path
      else
        render :action => "new"
      end

    end

    def destroy
      @page_route.destroy
      flash[:notice] = "Page Route Deleted"
      redirect_to page_routes_url
    end

    protected
    def load_page_route
      @page_route = PageRoute.find(params[:id])
    end

    private
    def page_route_params
      params.require(:page_route).permit(Cms::PageRoute.permitted_params)
    end

  end
end