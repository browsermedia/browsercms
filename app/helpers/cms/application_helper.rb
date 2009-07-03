# Methods added to this helper will be available to all templates in the cms.
module Cms
  module ApplicationHelper
    
    def searchable_sections(selected = nil)
      root = Section.root.first
      options = [['All sections', 'all'], [root.name, root.id]]
      root.all_children_with_name.each { |s|  options << [s.full_path, s.id] }
      options_for_select(options, selected.to_i)
    end

    def select_per_page
      options = [10, 20, 50, 100].collect { |c| ["#{c} per page", c] }
      select_tag("per_page", options_for_select(options, params[:per_page].to_i))
    end

    def page_versions(page)
      text = select_tag(:version, 
                        options_for_select(page.versions.all(:order => "version desc").map { |r| 
                                             ["v#{r.version}: #{r.version_comment} by #{r.updated_by.login} at #{time_on_date(r.updated_at)}", r.version] 
                                           }, page.version), 
                        :onchange => 'this.form.submit(); return false')
      text << javascript_tag("$('version').selectedIndex = 0") if page.live?
      text
    end

    def render_connector(connector)
      connectable = connector.connectable_with_deleted
      if logged_in? && @mode == "edit"
        if connectable.class.versioned?
          connectable = connectable.as_of_version(connector.connectable_version)
        end
        render :partial => 'cms/pages/edit_connector', 
          :locals => { :connector => connector, :connectable => connectable}
      else
        render_connectable(connectable)
      end
    end
    
    def render_connectable(content_block)
      if content_block
        if content_block.class.renderable?
          logger.info "..... Rendering connectable #{content_block.class} ##{content_block.id} #{"v#{content_block.version}" if content_block.respond_to?(:version)}"
          content_block.perform_render(@controller)
        else
          logger.warn "Connectable #{content_block.class} ##{content_block.id} is not renderable"
        end
      else
        logger.warn "Connectable is null"
      end    
    rescue Exception => e
      logger.error "Error occurred while rendering #{content_block.class}##{content_block.id}: #{e.message}\n#{e.backtrace.join("\n")}"
      "ERROR: #{e.message}"
    end
    
    def action_icon_src(name)
      "cms/icons/actions/#{name}.png"
    end
    
    def action_icon(name, options={})
      image_tag action_icon_src(name), {:alt => name.to_s.titleize}.merge(options)
    end

    def status_icon(status, options={})
      image_tag "cms/icons/status/#{status.to_s.underscore}.gif", {:alt => status.to_s.titleize}.merge(options)
    end
    
    def render_cms_toolbar(tab=:dashboard)
      render :partial => 'layouts/cms_toolbar', :locals => {:tab => tab}    
    end
    
    def link_to_usages(block)
      count = block.connected_pages.count
      if count > 0
        # Would love a cleaner solution to this problem, see http://stackoverflow.com/questions/702728
        path = Portlet === block ? usages_cms_portlet_path(block) : [:usages, :cms, block]
        link_to count, path, :id => block.id, :block_type => block.content_block_type
      else
        count
      end
    end
    
    def time_on_date(time)
      time && "#{time.strftime("%l:%M %p")} on #{time.strftime("%b %e, %Y")}"
    end

    def format_date(time)
      time && "#{time.strftime("%b %e, %Y")}"
    end
    
    def link_to_check_all(selector, name="Check All")
      link_to_function name, "$('#{selector}').attr('checked', true)"
    end

    def link_to_uncheck_all(selector, name="Uncheck All")
      link_to_function name, "$('#{selector}').attr('checked', false)"
    end
    
    def able_to?(*perms, &block)
      yield if current_user.able_to?(*perms)
    end
    
    def span_tag(content)
      content_tag :span, content
    end
    def lt_button_wrapper(content)
<<LBW
  <div class="lt_button">
    <img src="/images/cms/lt_button_l.gif" alt="" />
    <div class="lt_button_content">
      <span>#{ content }</span>
    </div>
    <img src="/images/cms/lt_button_r.gif" alt="" style="margin-right: 10px;" />
  </div>
LBW
    end

    def dk_button_wrapper(content)
      lt_button_wrapper(content).gsub("lt_button_","dk_button_")
    end
    def group_ids
      (params[:group_ids] || @user.group_ids).collect { |g| g.to_i }
    end

    def group_filter
      select_tag("group_id", options_from_collection_for_select(Group.all.insert(0, Group.new(:id => nil, :name => "Show All Groups")), "id", "name", params[:group_id].to_i))
    end	  	  
    
    def categories_for(category_type_name, order="name")
      cat_type = CategoryType.named(category_type_name).first
      cat_type ? cat_type.category_list(order) : []
    end	  
    
    def render_pagination(collection, collection_name, options={})
      if collection.blank?
        content_tag(:div, "No Content", :class => "pagination")
      else
        render :partial => "cms/shared/pagination", :locals => {
          :collection => collection,
          :first_page_path => send("cms_#{collection_name}_path", {:page => 1}.merge(options)),
          :previous_page_path => send("cms_#{collection_name}_path", {:page => collection.previous_page ? collection.previous_page : 1}.merge(options)),
          :current_page_path => send("cms_#{collection_name}_path", options),
          :next_page_path => send("cms_#{collection_name}_path", {:page => collection.next_page ? collection.next_page : collection.current_page}.merge(options)),
          :last_page_path => send("cms_#{collection_name}_path", {:page => collection.total_pages}.merge(options))
        }
      end
    end	  

    def url_with_mode(url, mode)
      uri = URI.parse(url)
      if uri.query =~ /mode=[^&]*/
        "#{uri.path}?#{uri.query.gsub(/((^|&)mode=)[^&]*/) {|s| "#{$1}#{mode}" }}"
      elsif uri.query
        "#{uri.path}?#{uri.query}&mode=#{mode}"
      else
        "#{uri.path}?mode=#{mode}"
      end
    end
    
    def determine_order(current_order, order)
      if current_order == order
        if order =~ / desc$/i
          order.sub(/ desc$/i, '')
        else
          order << ' desc'
        end
      else
        order
      end 
    end
    
  end
end
