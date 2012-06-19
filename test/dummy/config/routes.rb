Dummy::Application.routes.draw do

  # It is unclear why mounting the Engine doesn't just work here.
  match '/editor(/*requested_uri)' => "mercury#edit", :as => :mercury_editor
  scope '/mercury' do
    match ':type/:resource' => "mercury#resource"
    match 'snippets/:name/options' => "mercury#snippet_options"
    match 'snippets/:name/preview' => "mercury#snippet_preview"
  end

  get "content-page", :to=>"content_page#index"
  get "custom-page", :to=>"content_page#custom_page"
  namespace :cms do content_blocks :catalogs end
  namespace :cms do content_blocks :products end
  namespace :cms do content_blocks :sample_blocks end

  # For testing Acts::As::Page
  match "/__test__", :to => "cms/content#show_page_route"
  match "/tests/restricted", :to => "tests/pretend#restricted"
  match "/tests/open", :to => "tests/pretend#open"
  match "/tests/open_with_layout", :to => "tests/pretend#open_with_layout"
  match "/tests/error", :to => "tests/pretend#error"
  match "/tests/not-found", :to => "tests/pretend#not_found"

  mount_browsercms
end
