class NewsReleaseDetailsPortlet < Portlet
  
  def renderer(portlet)
    lambda do
      if params[:news_release_id]
        render :partial => portlet.class.partial, :locals => {:release => NewsRelease.find(params[:news_release_id])}
      else
        "<b>Missing required parameter</b><br/>This portlet expects a request parameter 'news_release_id'. Be sure the calling page provides it."
      end
    end
  end
    
end