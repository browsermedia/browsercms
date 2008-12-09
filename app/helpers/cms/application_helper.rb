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
  
    def render_connectable(block)
      instance_eval &block.renderer(block)
    rescue Exception => e
      logger.error "Error occurred while rendering #{block.class}:#{block.id}: #{e.message}\n#{e.backtrace.join("\n")}"
      "ERROR: #{e.message}"
    end
  
    def container(name)
      content = instance_variable_get("@content_for_#{name}")
      if logged_in? && @mode == "edit"
        render :partial => 'cms/pages/edit_container', :locals => {:name => name, :content => content}
      else
        content
      end
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
    
    def show_notice(page)
      page[:message].replace_html flash[:notice]
      flash.discard(:notice)
      page[:message].add_class_name 'notice'
      page[:message].remove_class_name 'error'
      page[:message].show
      page[:message].visual_effect :fade, :delay => 3      
    end
    
    def show_error(page)
      page[:message].replace_html flash[:error]
      flash.discard(:error)
      page[:message].add_class_name 'error'
      page[:message].remove_class_name 'notice'
      page[:message].show
      page[:message].visual_effect :fade, :delay => 3      
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
	    link_to_function name, "$$('#{selector}').each(function(box){ box.checked = true })"
	  end

    def link_to_uncheck_all(selector, name="Uncheck All")
	    link_to_function name, "$$('#{selector}').each(function(box){ box.checked = false })"
	  end
	  
	  def able_to?(*perms, &block)
	    yield if current_user.able_to?(*perms)
	  end
	  
	  def span_tag(content)
	    content_tag :span, content
    end
	  	  
    def group_ids
     (params[:group_ids] || @user.group_ids).collect { |g| g.to_i }
    end

    def group_filter
      select_tag("group_id", options_from_collection_for_select(Group.all.insert(0, Group.new(:id => nil, :name => "All")), "id", "name", params[:group_id].to_i))
    end	  	  
	  	  
	  def categories_for(category_type_name)
	    CategoryType.named(category_type_name).first.category_list
	  end	  
	  	  
	  def pagination(collection, path_args, record_type="Record")
	    if !collection || collection.size == 0
	      content = "No #{record_type.to_s.pluralize}"
	    elsif collection.size == 1
	      content = "1 #{record_type}"
	    elsif collection.total_entries <= collection.per_page
	      content = pluralize(collection.size, record_type)
	    else
	      build_link = lambda {|p|
	        args = path_args.dup
  	      if Hash === args.last
  	        args.last.merge(:page => p)
          else
            args << {:page => p}
          end
	      }
	      content = ""
	      content << link_to("Previous", cms_path(build_link.call(collection.previous_page))) if collection.previous_page
	      content << " #{record_type.to_s.pluralize} #{collection.offset + 1} - #{collection.offset + collection.size} of #{collection.size} "
	      content << link_to("Next", cms_path(build_link.call(collection.next_page))) if collection.next_page
      end
      content_tag(:div, content, :class => "pagination")
	  end	  
	  	  
  end
end