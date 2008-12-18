class NewsReleaseBrowserPortlet < Portlet
  
  def renderer(portlet)
    lambda do
      locals = {}
      if !portlet.category_id.blank?
        locals[:category] = Category.find(portlet.category_id)
        locals[:releases] = NewsRelease.all(:conditions => ["category_id = ?", locals[:category]], :order => "release_date desc", :limit => portlet.limit)
      else
        locals[:releases] = NewsRelease.all(:order => "release_date desc", :limit => portlet.limit)
      end
      logger.info "partial => #{portlet.partial}"
      render :partial => portlet.class.partial, :locals => locals
    end
  end
    
end