ActionController::Routing::Routes.draw do |map|

  map.namespace(:cms) do |cms|
    cms.logout '/logout', :controller => 'sessions', :action => 'destroy'
    cms.login '/login', :controller => 'sessions', :action => 'new'
    cms.dashboard '/', :controller => 'dashboard'
    cms.sitemap '/sitemap', :controller => 'sections'
    cms.content_library '/content_library', :controller => 'html_blocks'
    cms.administration '/administration', :controller => 'page_templates'

    cms.resources :connectors
    cms.resources :content_types, :collection => {:select => :get}
    cms.resources :html_blocks
    cms.resources :pages, :has_many => [:connectors], :member => {:publish => :put, :hide => :put, :archive => :put}
    cms.resources :page_templates
    cms.resources :portlet_types, :has_many => [:portlets]
    cms.resources :portlets
    cms.resources :sections, :has_many => [:pages, :sections]
    cms.resource :session
    cms.resources :users
  end
  
  map.page '*path', :controller => 'cms/pages', :action => 'show'
  
end