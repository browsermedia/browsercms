module Cms::Routes
  def routes_for_browser_cms

    namespace(:cms) do |cms|
      cms.home '/', :controller => 'home'
      cms.logout '/logout', :controller => 'sessions', :action => 'destroy'
      cms.login '/login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
      cms.connect '/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }      
      cms.dashboard '/dashboard', :controller => 'dashboard'
      cms.sitemap '/sitemap', :controller => 'section_nodes'
      cms.content_library '/content_library', :controller => 'blocks'
      cms.administration '/administration', :controller => 'users'
      cms.connect '/blocks/:block_type/:action/:id', :controller => 'blocks'
    end

    connect '/:controller/:action/:id.:format'
    connect '/:controller/:action.:format'
    connect '/:controller/:action/:id'
    connect '/:controller.:format'

    image_missing '/images/*path', :controller => 'cms/missing_asset'
    stylesheet_missing '/stylesheets/*path', :controller => 'cms/missing_asset'
    javascript_missing '/javascripts/*path', :controller => 'cms/missing_asset'

    connect '*path', :controller => 'cms/content', :action => 'show'    
  end
end
