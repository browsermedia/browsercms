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

    # These are for testing and might need to be stripped out.
    map.connect "/tests/restricted", :controller => "tests/pretend", :action => "restricted"
    map.connect "/tests/open", :controller => "tests/pretend", :action => "open"
    map.connect "/tests/error", :controller => "tests/pretend", :action => "error"
    map.connect "/tests/not-found", :controller => "tests/pretend", :action => "not_found"

    # Core CMS routes
    map.routes_for_browser_cms
  end
end
