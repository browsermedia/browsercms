Dummy::Application.routes.draw do

  namespace :cms  do content_blocks :deprecated_inputs end
  get "content-page", :to=>"content_page#index"
  get "custom-page", :to=>"content_page#custom_page"
  namespace :cms do content_blocks :catalogs end
  namespace :cms do content_blocks :products end
  namespace :cms do content_blocks :sample_blocks end

  # For testing Acts::As::Page
  get "/__test__", :to => "cms/content#show_page_route"
  get "/tests/restricted", :to => "tests/pretend#restricted"
  get "/tests/open", :to => "tests/pretend#open"
  get "/tests/open_with_layout", :to => "tests/pretend#open_with_layout"
  get "/tests/error", :to => "tests/pretend#error"
  get "/tests/not-found", :to => "tests/pretend#not_found"

  mount_browsercms
end
