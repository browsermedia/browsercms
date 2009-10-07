if RAILS_ENV == "test"
  class ContentBlock
    def self.versioned?; true; end
    def self.publishable?; true; end
    def self.connectable?; true; end
    def self.searchable?; false; end
  end
end      

ActionController::Routing::Routes.draw do |map|
  map.connect "/__test__", :controller => "cms/content", :action => "show_page_route"
  map.routes_for_browser_cms
end
