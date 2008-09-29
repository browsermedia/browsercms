# Methods added to this helper will be available to all templates in the cms.
module Cms
  module ApplicationHelper
  
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
      image_tag "cms/icons/status/#{status.underscore}.gif", {:alt => status.titleize}.merge(options)
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
      count = Connector.for_block(block).count
      count > 0 ? (link_to count,  :controller => "connectors", :action => "usages", :id => block.id, :block_type => block.content_block_type) : count
    end
  end
end