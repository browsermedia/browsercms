if RAILS_ENV == "test"
  class ContentBlock
    def self.versioned?; true; end
    def self.publishable?; true; end
    def self.connectable?; true; end
    def self.searchable?; false; end
  end
end      

# For BrowserCMS Core testing. These routes should not be used by projects that use BrowserCMS as a gem.
# Only load these routes if this is the "root" application
#
if RAILS_ROOT == File.expand_path(File.dirname(__FILE__) + "/..")
  ActionController::Routing::Routes.draw do |map|
    map.connect "/__test__", :controller => "cms/content", :action => "show_page_route"
    map.connect "/restricted", :controller => "tests/pretend", :action => "restricted"
    map.connect "/open", :controller => "tests/pretend", :action => "open"
    map.routes_for_browser_cms
  end
end
