# These routes make up what will be found under /cms
# There are other routes that will be added at the root of the site (i.e. /) which can
#   be found in lib/cms/route_extensions.rb
Cms::Engine.routes.draw do

  get 'fakemap', to: 'section_nodes#fake'
  get '/content/:id/edit', :to=>"content#edit", :as=>'edit_content'
  get '/dashboard', :to=>"dashboard#index", :as=>'dashboard'
  get '/', :to => 'home#index', :as=>'home'
  get '/sitemap', :to=>"section_nodes#index", :as=>'sitemap'
  get '/content_library', :to=>"html_blocks#index", :as=>'content_library'
  get '/administration', :to=>"users#index", :as=>'administration'
  get '/logout', :to=>"sessions#destroy", :as=>'logout'
  get '/login', :to=>"sessions#new", :as=>'login'
  post '/login', :to=>"sessions#create"

  get '/toolbar', :to=>"toolbar#index", :as=>'toolbar'

  put "/inline_content/:content_name/:id", to: "inline_content#update", as: "update_inline_content"
  resources :page_components
  resources :connectors do
    member do
      put :move_up
      put :move_down
      put :move_to_bottom
      put :move_to_top
    end
  end
  resources :links

  resources :pages do
    member do
      put :archive
      put :hide
      put :publish
      get :versions
    end
    collection do
      put :publish
    end
    resources :tasks
  end
  get '/pages/:id/preview', to: 'content#preview', as: 'preview_page'
  get '/pages/:id/version/:version', :to=>'pages#version', :as=>'version_cms_page'
  put '/pages/:id/revert_to/:version', :to=>'pages#revert_to', :as=>'revert_page'
  resources :tasks do
    member do
      put :complete
    end
    collection do
      put :complete
    end
  end
  resources :sections do
    resources :links, :pages
  end

  resources :section_nodes do
    member do
      put :move_to_position
    end
  end

  resources :attachments, :only=>[:show, :create, :destroy]

  content_blocks :html_blocks
  content_blocks :portlets
  post '/portlet/:id/:handler', :to=>"portlet#execute_handler", :as=>"portlet_handler"

  content_blocks :file_blocks
  content_blocks :image_blocks
  content_blocks :category_types
  content_blocks :categories
  content_blocks :tags
  resources :users do
    member do
      get :change_password
      patch :update_password
      put :disable
      put :enable
    end
  end
  resources :email_messages
  resources :groups
  resources :redirects
  resources :page_partials, :controller => 'dynamic_views'
  resources :page_templates, :controller => 'dynamic_views'
  resources :page_routes do
    resources :conditions, :controller => "page_route_conditions"
    resources :requirements, :controller => "page_route_requirements"
  end
  get 'cache', :to=>'cache#show', :as=>'cache'
  delete 'cache', :to=>'cache#destroy'

  get "/routes", :to => "routes#index", :as=>'routes'

end

