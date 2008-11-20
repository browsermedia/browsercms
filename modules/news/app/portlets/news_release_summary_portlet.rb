class NewsReleaseSummaryPortlet < Portlet
  
  def renderer(portlet)
    lambda do
      locals = {}
      if portlet.category_id
        locals[:category] = Category.find(portlet.category_id)
        locals[:releases] = NewsRelease.all(:conditions => ["category_id = ?", locals[:category]])
      else
        locals[:releases] = NewsRelease.all
      end
      render :partial => portlet.partial, :locals => locals
    end
  end
    
end