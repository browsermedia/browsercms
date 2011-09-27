module Cms
class RoutesController < Cms::BaseController
  
  
  def index
  
    @toolbar_tab = :administration
    
    unless params[:path].blank?
      @path = params[:path]
      @route = Rails.application.routes.recognize_path(@path)
    end
    
    @routes = Rails.application.routes.routes.collect do |route|
      name = route.name.to_s
      verb = route.verb
      segs = route.path
      reqs = route.requirements.empty? ? "" : route.requirements.inspect
      {:name => name, :verb => verb, :segs => segs, :reqs => reqs}
    end
    
  end
end
end