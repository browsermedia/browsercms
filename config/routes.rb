ActionController::Routing::Routes.draw do |map|

  map.namespace(:cms) do |cms|
    cms.logout '/logout', :controller => 'sessions', :action => 'destroy'
    cms.connect '/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }
    cms.login '/login', :controller => 'sessions', :action => 'new'
    cms.dashboard '/', :controller => 'dashboard'
    cms.sitemap '/sitemap', :controller => 'sections'
    cms.content_library '/content_library', :controller => 'html_blocks'
    cms.administration '/administration', :controller => 'page_templates'
    cms.connect '/blocks/:block_type/:action/:id', :controller => 'blocks'
  end

  map.connect '/:controller/:action/:id'

  map.page '*path', :controller => 'cms/pages', :action => 'show'
  
end