class NewsArchivePortlet < Portlet
  
  def self.default_template
    open(File.join(File.dirname(__FILE__), 
      "..", "views", "portlets", "news_archive", "_render.html.erb")) {|f| f.read}
  end  
  
  def renderer(portlet)
    lambda do
      locals = {}
      if portlet.category_id.blank?
        locals[:articles] = NewsArticle.all
      else
        locals[:category] = Category.find(portlet.category_id)
        locals[:articles] = NewsArticle.all(:conditions => ["category_id = ?", locals[:category]])        
      end
      render :inline => portlet.template, :locals => locals
    end
  end
    
end