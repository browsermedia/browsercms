module Cms
  module PageHelper

    # Return the JS file to load the configured default WYSIWYG editor
    #
    # Ideally, this could be improved if sprockets allows for dynamically determining which js library to use.
    def cms_content_editor
      "bcms/#{Cms.content_editor}"
    end

    # Outputs the title for this page. Used by both internal CMS pages, as well as page templates. If not explicitily set,
    #   returns the title of the page.
    #
    # @param [String] The name this page should be set to.
    # @return [String] The title of the page.
    def page_title(*args)
      if args.first
        # Removed unneeded indirection/fixed issue where @template is frozen in r1.9.1
        @page_title = args.first
      else
        @page_title ? @page_title : current_page.page_title
      end
    end    
    
    def current_page
      @page
    end

    # Outputs the content of a particular container. If the user is in 'edit' mode the container and block controls will
    # be rendered.
    #
    # @return [String] The HTML content for the container.
    def container(name)
      content = content_for(name)
      if logged_in? && @page && @mode == "edit" && current_user.able_to_edit?(@page)
        render :partial => 'cms/pages/edit_container', :locals => {:name => name, :content => content}
      else
        content
      end
    end    
    # Determine if a given container has any blocks within it. Useful for determine if markup should be conditionally included
    # when a block is present, but not shown if no block was added. For example:
    #
    # <% unless container_has_block? :sidebar %>
    #   <div id="sidebar">
    #   <%= container :sidebar %>
    #   </div>
    # <% end %>
    #
    # @param [Symbol] name The name of the container to check
    # @param [Proc] block
    # @return [Boolean] True if the container has one or more blocks, or if we are in edit mode. False otherwise. 
    def container_has_block?(name, &block)
      has_block = (@mode == "edit") || current_page.connectable_count_for_container(name) > 0
      logger.info "mode = #{@mode}, has_block = #{has_block}"
      if block_given?
        concat(capture(&block)) if has_block
      else
        has_block
      end
    end

    # Add the code to render the CMS toolbar.
    def cms_toolbar
      toolbar = <<HTML
<iframe src="#{cms.toolbar_path(:page_id => @page.id, :page_version => @page.version, :mode => @mode, :page_toolbar => @show_page_toolbar ? 1 : 0) }" width="100%" height="#{@show_page_toolbar ? 159 : 100 }px" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" name="cms_toolbar"></iframe>
HTML
      toolbar.html_safe if @show_toolbar
    end



    # Renders breadcrumbs based on the current_page. This will generate an unordered list representing the
    # current page and all it's ancestors including the root name of of the site. The UL can be styled via CSS for
    # layout purposes. Each breadcrumb except the last will be linked to the page in question.
    #
    # If the current_page is nil, it will return an empty string.
    #
    # ==== Params:
    #   options = A hash of options which determine how the breadcrumbs will be laid out.
    #
    # ==== Options:
    # * <tt>:from_top</tt> - How many below levels from the root the tree should start at.
    #   All sections at this level will be shown.  The default is 0, which means show all
    #   nodes that are direct children of the root.
    # * <tt>:show_parent</tt> - Determines if the name of the page itself show be shown as a breadcrumb link. Defaults to false, meaning
    #   that the parent section of the current page will be the 'last' breadcrumb link. (Note: This probably better renamed as 'show_page').
    #
    def render_breadcrumbs(options={})
      return "" unless current_page

      start = options[:from_top] || 0
      show_parent = options[:show_parent].nil? ? false : options[:show_parent]
      ancestors = current_page.ancestors
      items = []
      ancestors[start..ancestors.size].each_with_index do |sec,i|
        items << content_tag(:li, 
          link_to(sec.name, sec.actual_path), (i == 0 ? {:class => "first"} : {}))
      end
      if !show_parent && current_page.section.path == current_page.path
        items[items.size-1] = content_tag(:li, current_page.section.name)
      else
        items << content_tag(:li, current_page.page_title)
      end
      content_tag(:ul, "\n  #{items.join("\n  ")}\n".html_safe, :class => "breadcrumbs")
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

    # Determines if the current_user is able to do specific permissions.
    def able_to?(*perms, &block)
      block.call if current_user.able_to?(*perms)
      return ''
    end

  end
end
