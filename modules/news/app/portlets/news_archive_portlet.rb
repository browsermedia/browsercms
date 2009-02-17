class NewsArchivePortlet < Portlet
  
  def renderer(portlet)
    lambda do
      locals = {}
      if portlet.category_id.blank?
        locals[:articles] = NewsArticle.all
      else
        locals[:category] = Category.find(portlet.category_id)
        locals[:articles] = NewsArticle.all(:conditions => ["category_id = ?", locals[:category]])        
      end
      render :partial => portlet.class.partial, :locals => locals
    end
  end
    
end