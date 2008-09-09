ActionController::Routing::Routes.draw do |map|

  map.namespace(:cms) do |cms|
    cms.logout '/logout', :controller => 'sessions', :action => 'destroy'
    cms.connect '/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }
    cms.login '/login', :controller => 'sessions', :action => 'new'
    cms.dashboard '/', :controller => 'dashboard'
    cms.sitemap '/sitemap', :controller => 'sections'
    cms.content_library '/content_library', :controller => 'html_blocks'
    cms.administration '/administration', :controller => 'page_templates'
    # cms.resources :connectors, :member => {:move_up => :put, :move_down => :put, :move_to_top => :put, :move_to_bottom => :put}
    # cms.resources :content_types, :collection => {:select => :get}
    # cms.resources :html_blocks
    # cms.move_page_to_section '/pages/:id/move_to/:section_id', :controller => 'pages', :action => 'move_to', :conditions => { :method => :put }
    # cms.formatted_move_page_to_section '/pages/:id/move_to/:section_id.:format', :controller => 'pages', :action => 'move_to', :conditions => { :method => :put }
    # cms.resources :pages, :has_one => :section, :has_many => [:connectors], :member => {:publish => :put, :hide => :put, :archive => :put, :move => :get}
    # cms.resources :page_templates
    # cms.resources :portlet_types, :has_many => [:portlets]
    # cms.resources :portlets
    # cms.move_section_to '/sections/:id/move_to/:section_id', :controller => 'sections', :action => 'move_to', :conditions => { :method => :put }
    # cms.formatted_move_section_to '/sections/:id/move_to/:section_id.:format', :controller => 'sections', :action => 'move_to', :conditions => { :method => :put }
    # cms.resources :sections, :has_many => [:pages, :sections], :member => {:move => :get}
    # cms.resource :session
    # cms.resources :users
  end

  map.connect '/:controller/:action/:id'

  map.page '*path', :controller => 'cms/pages', :action => 'show'
  
end