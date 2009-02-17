class NewsArticlePortlet < Portlet
  
  def renderer(portlet)
    lambda do
      if params[:news_article_id]
        render :partial => portlet.class.partial, :locals => {:article => NewsArticle.find(params[:news_article_id])}
      else
        "<b>Missing required parameter</b><br/>This portlet expects a request parameter 'news_article_id'. Be sure the calling page provides it."
      end
    end
  end
    
end