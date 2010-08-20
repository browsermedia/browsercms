# This is the 'old' version of the routing file.
# It should be deleted prior to releasing the gem, and all test related data moved elsewhere.
if Rails.env == "test"
  class ContentBlock
    def self.versioned?; true; end
    def self.publishable?; true; end
    def self.connectable?; true; end
    def self.searchable?; false; end
  end
end      

# For BrowserCMS Core testing. These routes should not be used by projects that use BrowserCMS as a gem.
# Only load these routes if this is the "root" application

if Rails.root == File.expand_path(File.dirname(__FILE__) + "/..")
  Browsercms::Application.routes.draw do |map|

#  ActionController::Routing::Routes.draw do |map|
    map.connect "/__test__", :controller => "cms/content", :action => "show_page_route"

    # These are for testing and might need to be stripped out.
    map.connect "/tests/restricted", :controller => "tests/pretend", :action => "restricted"
    map.connect "/tests/open", :controller => "tests/pretend", :action => "open"
    map.connect "/tests/open_with_layout", :controller => "tests/pretend", :action => "open_with_layout"
    map.connect "/tests/error", :controller => "tests/pretend", :action => "error"
    map.connect "/tests/not-found", :controller => "tests/pretend", :action => "not_found"

    # Core CMS routes
    map.routes_for_browser_cms

    # Both of these work for testing purposes. Figure out why its not working from within a method call (routes_for_browser_cms).
    # This isn't a long term solution
#    match "/", :to=>"cms/content#show"
#    match "*path", :to=>"cms/content#show"

  end
end


