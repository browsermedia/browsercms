namespace(:cms) do |cms|
  cms.logout '/logout', :controller => 'sessions', :action => 'destroy'
  cms.connect '/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }
  cms.login '/login', :controller => 'sessions', :action => 'new'
  cms.dashboard '/', :controller => 'dashboard'
  cms.sitemap '/sitemap', :controller => 'sections'
  cms.content_library '/content_library', :controller => 'blocks'
  cms.administration '/administration', :controller => 'page_templates'
  cms.connect '/blocks/:block_type/:action/:id', :controller => 'blocks'
end

connect '/:controller/:action/:id.:format'
connect '/:controller/:action/:id'

page '*path', :controller => 'cms/pages', :action => 'show'