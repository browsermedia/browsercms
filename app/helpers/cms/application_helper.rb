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
      text << javascript_tag("$('version').selectedIndex = 0") if page.current_version?
      text
    end

    def render_connector(connector)
      if logged_in? && @mode == "edit"
        render :partial => 'cms/pages/edit_connector', :locals => {:connector => connector}
      else
        render_connectable(connector.current_connectable)
      end
    end
    
    def render_connectable(content_block)
      if content_block
        logger.info "Rendering connectable #{content_block.class} ##{content_block.id}"
        render_proc = content_block.renderer(content_block)
        instance_eval &render_proc
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
    
    def cms_toolbar(tab=:dashboard)
      render :partial => 'layouts/cms_toolbar', :locals => {:tab => tab}    
    end
    
    def link_to_usages(block)
      count = block.connected_pages.count
      count > 0 ? (link_to count,  :controller => "connectors", :action => "usages", :id => block.id, :block_type => block.content_block_type) : count
    end
    
    def time_on_date(time)
      "#{time.strftime("%l:%M %p")} on #{time.strftime("%b %e, %Y")}"
    end

    def format_date(time)
      "#{time.strftime("%b %d, %Y")}"
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
    <div>
      #{ content }
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
    
    def categories_for(category_type_name)
      CategoryType.named(category_type_name).first.category_list
    end	  
    
    def pagination(collection, path_args, record_type="Record")
      return content_tag(:div, "No Content", :class => "pagination") unless collection.size > 0
        build_link = lambda {|p|
          args = path_args.dup
          if Hash === args.last
            args.last.merge(:page => p)
          else
            args << {:page => p}
          end
        }
      content_info = content_tag(:div,"Displaying #{collection.offset + 1} - #{collection.offset + collection.size} of #{collection.total_entries} ", :class => "info")

      content_links = link_to("&nbsp;", cms_path(*build_link.call(1)), :id => "first_page_link") 
      content_links << link_to("&nbsp;", cms_path(*build_link.call(collection.previous_page ? collection.previous_page : 1)), :id => "previous_page_link")
      content_links << content_tag(:span, "Page <strong>#{collection.current_page}</strong> of <strong>#{collection.total_pages}</strong>")
      content_links << link_to("&nbsp;", cms_path(*build_link.call(collection.next_page ? collection.next_page : collection.current_page)), :id => "next_page_link")
      content_links << link_to("&nbsp;", cms_path(*build_link.call(collection.total_pages)), :id => "last_page_link")
      content_links_div = content_tag(:div, content_links, :class => "links")
      content_tag(:div, content_info + content_links_div + '<br clear="all" />', :class => "pagination")
    end	  
    
    def connectable_content_types
      cts = ContentType.all(:order => "name")
      useful_cts = []
      cts.each do |type|
        next unless type.model_class.instance_methods.include?('connect_to_container') 
        useful_cts << type
      end
      useful_cts.each {|t| logger.debug "#{t.display_name} == Text: #{t.display_name == 'Text'}" }
      useful_cts
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
    
    def tb_iframe(path, options={})
      # The order of the parameters matters.  All parameters that should be sent to the server,
      # have to appear before TB_iframe.  All parameters that shouldn't be sent to the server and
      # that are just there for Thickbox should be after TB_iframe
      {:height => 600, :width => 600, :modal => true}.merge(options).inject("#{path}&TB_iframe=true") do |s, (k,v)|
        s << "&#{k}=#{CGI::escape(v.to_s)}"
      end
    end
    
  end
end
