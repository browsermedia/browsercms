class NewsRssPortlet < Portlet
  
  def self.default_template
    open(File.join(File.dirname(__FILE__), 
      "..", "views", "portlets", "news_rss", "_render.xml.erb")) {|f| f.read}
  end  
  
  def renderer(portlet)
    lambda do
      locals = {}
      if !portlet.category_id.blank?
        locals[:category] = Category.find(portlet.category_id)
        locals[:articles] = NewsArticle.all(:conditions => ["category_id = ?", locals[:category]], :order => "release_date desc", :limit => portlet.limit)
      else
        locals[:articles] = NewsArticle.all(:order => "release_date desc", :limit => portlet.limit)
      end
      locals[:portlet] = portlet
      render :inline => portlet.template, :locals => locals
    end
  end
    
end