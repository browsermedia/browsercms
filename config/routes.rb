if Rails.env == "test"
  class SampleBlock
    def self.versioned?; true; end
    def self.publishable?; true; end
    def self.connectable?; true; end
    def self.searchable?; false; end
  end

  class Cms::SampleBlocksController < Cms::ContentBlockController
  end
end
Browsercms::Application.routes.draw do |map|

  match "/__test__", :to => "cms/content#show_page_route"

  # These are for testing and might need to be stripped out.
  match "/tests/restricted", :to => "tests/pretend#restricted"
  match "/tests/open", :to => "tests/pretend#open"
  match "/tests/open_with_layout", :to => "tests/pretend#open_with_layout"
  match "/tests/error", :to => "tests/pretend#error"
  match "/tests/not-found", :to => "tests/pretend#not_found"

  if Rails.env == "test"
    namespace :cms do
      content_blocks :sample_blocks
    end
  end
  routes_for_browser_cms


end