Dummy::Application.routes.draw do

  namespace :dummy do content_blocks :products end
  namespace :dummy  do content_blocks :deprecated_inputs end
  get "content-page", :to=>"content_page#index"
  get "custom-page", :to=>"content_page#custom_page"
  namespace :dummy do content_blocks :catalogs end
  namespace :dummy do content_blocks :sample_blocks end

  # For testing Acts::As::Page
  get "/__test__", :to => "cms/content#show_page_route"
  get "/tests/restricted", :to => "tests/pretend#restricted"
  get "/tests/open", :to => "tests/pretend#open"
  get "/tests/open_with_layout", :to => "tests/pretend#open_with_layout"
  get "/tests/error", :to => "tests/pretend#error"
  get "/tests/not-found", :to => "tests/pretend#not_found"

  get "/design/:page", to: "design#show"
  mount_browsercms
end
