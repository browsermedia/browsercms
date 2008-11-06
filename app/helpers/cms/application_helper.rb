# Methods added to this helper will be available to all templates in the cms.
module Cms
  module ApplicationHelper

    def searchable_sections(selected = nil)
      root = Section.root.first
      options = [['All sections', 'all'], [root.name, root.id]]
      root.all_children_with_name.each { |s|  options << [s.full_path, s.id] }
      options_for_select(options, selected)
    end

    def select_per_page
      options = [10, 20, 50, 100].collect { |c| ["#{c} per page", c] }
      select_tag("per_page", options_for_select(options, params[:per_page].to_i))
    end

    def page_versions(page)
      text = select_tag(:version, 
                        options_for_select(page.versions.all(:order => "version desc").map { |r| 
                          ["v#{r.version}: #{r.revision_comment} by #{r.updated_by.login} at #{time_on_date(r.updated_at)}", r.version] 
                        }, page.version), 
                        :onchange => 'this.form.submit(); return false')
      text << javascript_tag("$('version').selectedIndex = 0") if page.current_version?
      text
    end

    def render_connector(connector)
      if logged_in? && @mode == "edit"
        render :partial => 'cms/pages/edit_connector', :locals => {:connector => connector}
      else
        render_content_block(connector.content_block)
      end
    end
  
    def render_content_block(block)
      block.request = request if block.respond_to?(:request=)
      block.response = request if block.respond_to?(:response=)
      block.params = request if block.respond_to?(:params=)
      block.session = request if block.respond_to?(:session=)
      block.render
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
  
    def cms_toolbar
      render :partial => 'layouts/cms_toolbar'    
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
	  	  
  end
end