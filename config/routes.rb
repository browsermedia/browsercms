ActionController::Routing::Routes.draw do |map|
  map.connect "/__test__", :controller => "cms/content", :action => "show_page_route"
  map.routes_for_browser_cms
end