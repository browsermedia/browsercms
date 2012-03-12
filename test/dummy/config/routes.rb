Rails.application.routes.draw do

  get "content-page", :to=>"content_page#index"
  get "custom-page", :to=>"content_page#custom_page"

  namespace :cms  do content_blocks :products end


  # These are for testing
  match "/__test__", :to => "cms/content#show_page_route"

  match "/tests/restricted", :to => "tests/pretend#restricted"
  match "/tests/open", :to => "tests/pretend#open"
  match "/tests/open_with_layout", :to => "tests/pretend#open_with_layout"
  match "/tests/error", :to => "tests/pretend#error"
  match "/tests/not-found", :to => "tests/pretend#not_found"
  namespace :cms do
    content_blocks :sample_blocks
  end

  # Actual browsercms engine
  mount_browsercms
end
