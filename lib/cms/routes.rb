module Cms::Routes
  
  def content_blocks(content_block_name, options={}, &block)
    content_block = content_block_name.to_s.classify.constantize
    resources(*[content_block_name, default_routes_for_content_block(content_block).deep_merge(options)], &block)
    if content_block.versioned?
      # I'm not sure why, but these named routes 
      # don't end up getting nested in the CMS namepace.
      # So for now I'm just hard-coding the stuff related to the CMS namespace
      send("version_cms_#{content_block_name}".to_sym, 
        "/cms/#{content_block_name}/:id/version/:version",
        :controller => "cms/#{content_block_name}",
        :action => "version",
        :conditions => {:method => :get})
      send("revert_to_cms_#{content_block_name}".to_sym, 
        "/cms/#{content_block_name}/:id/revert_to/:version",
        :controller => "cms/#{content_block_name}",
        :action => "revert_to",
        :conditions => {:method => :put})
    end
  end
  
  def default_routes_for_content_block(content_block)
    member_routes = {}
    member_routes[:publish] = :put if content_block.publishable?
    member_routes[:versions] = :get if content_block.versioned?
    member_routes[:usages] = :get if content_block.connectable?    
    {:member => member_routes}
  end
  
  def routes_for_browser_cms

    namespace(:cms) do |cms|
      
      cms.home '/', :controller => 'home'
      
      cms.logout '/logout', :controller => 'sessions', :action => 'destroy'
      cms.login '/login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
      cms.connect '/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }      
      cms.dashboard '/dashboard', :controller => 'dashboard'
      cms.sitemap '/sitemap', :controller => 'section_nodes'

      cms.content_types '/content_types', :controller => 'content_types'
      cms.resources :connectors, :member => {
        :move_up => :put,
        :move_down => :put,
        :move_to_bottom => :put,
        :move_to_top => :put
      }
      cms.resources :links

      cms.resources :pages, :member => {
        :archive => :put,
        :hide => :put,
        :publish => :put,
        :versions => :get
      }, :collection => {
        :publish => :put
      }, :has_many => [:tasks]
      version_cms_page '/cms/pages/:id/version/:version', :controller => 'cms/pages', :action => 'version', :conditions => {:method => :get}
      revert_to_cms_page '/cms/pages/:id/revert_to/:version', :controller => 'cms/pages', :action => 'revert_to', :conditions => {:method => :put}

      cms.file_browser '/sections/file_browser.xml', :controller => 'sections', :action => 'file_browser', :format => "xml"
      cms.resources :sections, :has_many => [:links, :pages]

      cms.resources :section_nodes, :member => {
        :move_before => :put,
        :move_after => :put,
        :move_to_beginning => :put,
        :move_to_end => :put,
        :move_to_root => :put
      }
      cms.attachment '/attachments/:id', :controller => 'attachments', :action => 'show'

      cms.resources :tasks, :member => {:complete => :put}, :collection => {:complete => :put}
      cms.toolbar '/toolbar', :controller => 'toolbar'
      
      # TODO: Make an actual content library controller 
      # that redirects to the last content type you were working on
      cms.content_library '/content_library', :controller => 'html_blocks' 
      
      cms.content_blocks :html_blocks
      cms.content_blocks :portlets, :member => {:usages => :get}
      cms.handler "/portlet/:id/:handler", 
        :controller => "portlet", 
        :action => "execute_handler", 
        :conditions => {:method => :post}
      
      cms.content_blocks :file_blocks
      cms.content_blocks :image_blocks
      cms.content_blocks :category_types
      cms.content_blocks :categories
      cms.content_blocks :tags
      
      cms.administration '/administration', :controller => 'users'
      
      cms.with_options :controller => "cache" do |cache|
          cache.cache "/cache", :action => "show", :conditions => {:method => :get}
        cache.connect "/cache", :action => "destroy", :conditions => {:method => :delete}
      end
            
      cms.resources :email_messages
      cms.resources :groups
      cms.resources :redirects
      cms.resources :page_partials, :controller => 'dynamic_views'
      cms.resources :page_templates, :controller => 'dynamic_views'
      cms.resources :page_routes do |pr|
        pr.resources :conditions, :controller => "page_route_conditions"
        pr.resources :requirements, :controller => "page_route_requirements"
      end
      cms.routes "/routes", :controller => "routes"
      cms.resources :users, :member => {
        :change_password => :get, 
        :update_password => :put,
        :disable => :put, 
        :enable => :put
      }
      
    end

    if PageRoute.table_exists?
      PageRoute.all(:order => "page_routes.name").each do |r|
        send((r.route_name || 'connect').to_sym, r.pattern, r.options_map)
      end
    end

    connect '*path', :controller => 'cms/content', :action => 'show'    
  end
end
