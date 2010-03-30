module Cms
class PageRouteOptionsController < Cms::BaseController

  before_filter :load_page_route
  before_filter :load_model, :only => [:edit, :update, :destroy]
  
  def new
    @model = resource.new
  end
  
  def create
    @model = resource.new(params[object_name])
    if @model.save
      flash[:notice] = "#{object_name.titleize} added"
      redirect_to cms_page_route_url(@page_route)
    else
      render :action => "new"
    end
  end
  
  def update
    if @model.update_attributes(params[object_name])
      flash[:notice] = "#{object_name.titleize} updated"
      redirect_to cms_page_route_url(@page_route)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @model.destroy
    flash[:notice] = "#{object_name.titleize} deleted"
    redirect_to cms_page_route_url(@page_route)
  end
  
  protected
    def load_page_route
      @page_route
    end
  
    def load_model
      @model = resource.find(params[:id])      
    end
  
    def resource
      @page_route.send(resource_name.pluralize)
    end
  
    def resource_name
      self.class.name.match(/Cms::PageRoute(\w+)Controller/)[1].downcase.singularize
    end
    
    def object_name
      "page_route_#{resource_name}"
    end
    
end
end