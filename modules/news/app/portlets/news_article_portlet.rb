class NewsArticlePortlet < Portlet
  
  def self.default_template
    open(File.join(File.dirname(__FILE__), 
      "..", "views", "portlets", "news_article", "_render.html.erb")) {|f| f.read}
  end  
  
  def renderer(portlet)
    lambda do
      if params[:news_article_id]
        render :inline => portlet.template, :locals => {:article => NewsArticle.find(params[:news_article_id])}
      else
        "<b>Missing required parameter</b><br/>This portlet expects a request parameter 'news_article_id'. Be sure the calling page provides it."
      end
    end
  end
    
end