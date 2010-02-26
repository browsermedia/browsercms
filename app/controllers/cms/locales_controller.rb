class Cms::LocalesController < Cms::BaseController
  
  def index
    cookies[:locale] = params[:locale]
    redirect_to request.env["HTTP_REFERER"]
  end
  
  def jslocales
    render :js => "var BCMSLocales = " + I18n.t("js").to_json
  end
  
end