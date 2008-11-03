namespace(:cms) do |cms|
  cms.logout '/logout', :controller => 'sessions', :action => 'logout'
  cms.login '/login', :controller => 'sessions', :action => 'login'
  cms.dashboard '/', :controller => 'dashboard'
  cms.sitemap '/sitemap', :controller => 'section_nodes'
  cms.content_library '/content_library', :controller => 'blocks'
  cms.administration '/administration', :controller => 'users'
  cms.connect '/blocks/:block_type/:action/:id', :controller => 'blocks'
end

connect '/:controller/:action/:id.:format'
connect '/:controller/:action.:format'
connect '/:controller/:action/:id'

connect '*path', :controller => 'cms/content', :action => 'show'