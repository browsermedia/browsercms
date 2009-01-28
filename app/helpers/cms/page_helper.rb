module Cms
  module PageHelper
    def current_page
      @page
    end
    
    def container(name)
      content = instance_variable_get("@content_for_#{name}")
      if logged_in? && @mode == "edit"
        render :partial => 'cms/pages/edit_container', :locals => {:name => name, :content => content}
      else
        content
      end
    end
    
    def cms_toolbar
      instance_variable_get("@content_for_layout")
    end
    
  end
end