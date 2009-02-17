class RecentNewsPortlet < Portlet
  
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
      render :partial => portlet.class.partial, :locals => locals
    end
  end
    
end