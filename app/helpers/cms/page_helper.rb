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
    
    def render_breadcrumbs(options={})
      start = options[:from_top] || 0
      ancestors = current_page.ancestors
      items = []
      ancestors[start..ancestors.size].each_with_index do |sec,i|
        items << content_tag(:li, 
          link_to(h(sec.name), sec.actual_path), 
          (i == 0 ? {:class => "first"} : {}))
      end
      items << content_tag(:li, current_page.page_title)
      content_tag(:ul, "\n  #{items.join("\n  ")}\n", :class => "breadcrumbs")
    end
    
  end
end