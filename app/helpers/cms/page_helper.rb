module Cms
  module PageHelper
    def page_title(*args)
      if args.first
        @controller.instance_variable_get("@template").instance_variable_set("@page_title", args.first)
      else
        @controller.instance_variable_get("@template").instance_variable_get("@page_title")
      end
    end    
    
    def current_page
      @page
    end
    
    def container(name)
      content = instance_variable_get("@content_for_#{name}")
      if logged_in? && @page && @mode == "edit"
        render :partial => 'cms/pages/edit_container', :locals => {:name => name, :content => content}
      else
        content
      end
    end
    
    def container_has_block?(name, &block)
      has_block = (@mode == "edit") || current_page.connectable_count_for_container(name) > 0
      logger.info "mode = #{@mode}, has_block = #{has_block}"
      if block_given?
        concat(capture(&block)) if has_block
      else
        has_block
      end
    end
    
    def cms_toolbar
      instance_variable_get("@content_for_layout")
    end
    
    def render_breadcrumbs(options={})
      start = options[:from_top] || 0
      show_parent = options[:show_parent].nil? ? false : options[:show_parent]
      ancestors = current_page.ancestors
      items = []
      ancestors[start..ancestors.size].each_with_index do |sec,i|
        items << content_tag(:li, 
          link_to(h(sec.name), sec.actual_path), 
          (i == 0 ? {:class => "first"} : {}))
      end
      if !show_parent && current_page.section.path == current_page.path
        items[items.size-1] = content_tag(:li, h(current_page.section.name))
      else
        items << content_tag(:li, h(current_page.page_title))
      end
      content_tag(:ul, "\n  #{items.join("\n  ")}\n", :class => "breadcrumbs")
    end
    
    def render_portlet(name)
      portlets = Portlet.all(:conditions => ["name = ?", name.to_s])
      if portlets.size > 1
        @mode == "edit" ? "ERROR: Multiple Portlets with name '#{name}'" : nil
      elsif portlets.empty?
        @mode == "edit" ? "ERROR: No Portlet with name '#{name}'" : nil
      else
        render_connectable(portlets.first)
      end
    end
            
  end
end