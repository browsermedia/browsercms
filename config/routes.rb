# These routes make up what will be found under /cms
# There are other routes that will be added at the root of the site (i.e. /) which can
#   be found in lib/cms/route_extensions.rb
Cms::Engine.routes.draw do
  get 'fakemap', to: 'section_nodes#fake'
  get '/content/:id/edit', :to => "content#edit", :as => 'edit_content'
  get '/dashboard', :to => "dashboard#index", :as => 'dashboard'
  get '/', :to => 'home#index', :as => 'home'
  get '/sitemap', :to => "section_nodes#index", :as => 'sitemap'
  get '/content_library', :to => "html_blocks#index", :as => 'content_library'
  get '/administration', :to => "users#index", :as => 'administration'

  devise_for :cms_users,
             skip: [:sessions],
             path: :users,
             class_name: 'Cms::PersistentUser',
             controllers: {passwords: 'cms/passwords'},
             module: :devise

  devise_scope :cms_user do
    get '/login' => "sessions#new", :as => 'login'
    get '/login' => "sessions#new", :as => :new_cms_user_session
    post '/login' => "sessions#create", :as => :cms_user_session
    get '/logout' => "sessions#destroy", :as => 'logout'

  end

  get '/toolbar', :to => "toolbar#index", :as => 'toolbar'

  put "/inline_content/:id", to: "inline_content#update", as: "update_inline_content"
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

  resources :content_types, only: [] do
    collection do
      post :index
    end
  end
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
  get '/pages/:id/version/:version', :to => 'pages#version', :as => 'version_page'
  put '/pages/:id/revert_to/:version', :to => 'pages#revert_to', :as => 'revert_page'
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

  resources :attachments, :only => [:show, :create, :destroy]

  content_blocks :html_blocks
  content_blocks :forms
  resources :form_fields do
    member do
      get :confirm_delete
    end
  end
  post "form_fields/:id/insert_at/:position" => 'form_fields#insert_at'
  get "/forms/:id/fields/preview" => 'form_fields#preview', as: 'preview_form_field'

  resources :form_entries do
    collection do
      post :submit
    end
  end
  put "/form_entries" => "form_entries#bulk_update"
  # Faux nested resource for forms (not sure if #content_blocks allows for it.)
  get 'forms/:id/entries' => 'form_entries#index', as: 'entries'

  content_blocks :portlets
  post '/portlet/:id/:handler', :to => "portlet#execute_handler", :as => "portlet_handler"

  content_blocks :file_blocks
  content_blocks :image_blocks
  content_blocks :category_types
  content_blocks :categories
  content_blocks :tags

  get 'user' => "user#show", as: :current_user
  resources :users, except: :show do
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
  resources :page_routes, except: :show do
    resources :conditions, :controller => "page_route_conditions"
    resources :requirements, :controller => "page_route_requirements"
  end
  get 'cache', :to => 'cache#show', :as => 'cache'
  delete 'cache', :to => 'cache#destroy'

  get "/routes", :to => "routes#index", :as => 'routes'

  add_routes_for_addressable_content_blocks
end

