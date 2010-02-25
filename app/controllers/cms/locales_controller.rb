class Cms::LocalesController < Cms::BaseController
  
  def index
    cookies[:locale] = params[:locale]
    redirect_to request.env["HTTP_REFERER"]
  end
  
end