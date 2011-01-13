module Cms::Routes


  # Adds all necessary routes to manage a new content type. Works very similar to the Rails _resources_ method, adding basic CRUD routes, as well as additional ones
  #   for CMS specific routes (like versioning)
  #
  # @params [Symbol] content_block_name - The plural name of a new Content Type. Should match the name of the content_block, like :dogs or :donation_statuses
  def content_blocks(content_block_name, options={}, & block)
    content_block = content_block_name.to_s.classify.constantize
    resources content_block_name do
      member do
        put :publish if content_block.publishable?
        get :versions if content_block.versioned?
        get :usages if content_block.connectable?
      end
    end
    if content_block.versioned?
      send("get", "/#{content_block_name}/:id/version/:version", :to=>"cms/#{content_block_name}#version", :as=>"version_cms_#{content_block_name}".to_sym)
      send("put", "/#{content_block_name}/:id/revert_to/:version", :to=>"cms/#{content_block_name}#revert_to", :as=>"revert_to_cms_#{content_block_name}".to_sym)
    end
  end

  # Adds the routes required for BrowserCMS to function to a routes.rb file. Should be the last route in the file, as
  # all following routes will be ignored.
  #
  # Usage:
  #   YourApp::Application.routes.draw do |map|
  #      routes_for_browser_cms
  #   end
  #
  def routes_for_browser_cms

    namespace :cms do

      match '/dashboard', :to=>"dashboard#index", :as=>'dashboard'
      # I want to do the following instead
      # match '/dashboard', :to=>"dashboard#index", :as=>'dashboard'

      match '/', :to => 'home#index', :as=>'home'
      match '/sitemap', :to=>"section_nodes#index", :as=>'sitemap'
      match '/content_library', :to=>"html_blocks#index", :as=>'content_library'
      match '/administration', :to=>"users#index", :as=>'administration'
      match '/logout', :to=>"sessions#destroy", :as=>'logout'
      get '/login', :to=>"sessions#new", :as=>'login'
      post '/login', :to=>"sessions#create"

      match '/toolbar', :to=>"toolbar#index", :as=>'toolbar'
      match '/content_types', :to=>"content_types#index", :as=>'content_types'

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
      get '/pages/:id/version/:version', :to=>'cms/pages#version', :as=>'version_cms_page'
      put '/pages/:id/revert_to/:version', :to=>'cms/pages#revert_to', :as=>'revert_to_cms_page'
      resources :tasks do
        member do
          put :complete
        end
        collection do
          put :complete
        end
      end
      match '/sections/file_browser.xml', :to => 'cms/sections#file_browser', :format => "xml", :as=>'file_browser'
      resources :sections do
        resources :links, :pages
      end

      resources :section_nodes do
        member do
          put :move_before
          put :move_after
          put :move_to_beginning
          put :move_to_end
          put :move_to_root
        end
      end
      match '/attachments/:id', :to => 'cms/attachments#show', :as=>'attachment'

      match '/content_library', :to=>'cms/html_blocks#index', :as=>'content_library'
      content_blocks :html_blocks
      content_blocks :portlets do
        member do
          get :usages
        end
      end
      post '/portlet/:id/:handler', :to=>"cms/portlet#execute_handler"

      content_blocks :file_blocks
      content_blocks :image_blocks
      content_blocks :category_types
      content_blocks :categories
      content_blocks :tags

      match '/administration', :to => 'cms/users#index', :as=>'administration'

      resources :users do
        member do
          get :change_password
          put :update_password
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
      get 'cache', :to=>'cms/cache#show', :as=>'cache'
      delete 'cache', :to=>'cms/cache#destroy'

      # This is only for testing, and should be moved to the config/routes.rb file eventually.
#      content_blocks :sample_blocks

      match  "/routes", :to => "cms/routes#index", :as=>'routes'

    end

#    # Loads all page routes from the database (Currently disabled since Rails 3 routing syntax for options is different
#    if PageRoute.table_exists?
#      PageRoute.all(:order => "page_routes.name").each do |r|
#        # This next line should ideally work
#        send('match', r.pattern, :to=>r.options_map, :as=>r.route_name)
#        # This was the Rails 2 version of this
#        send((r.route_name || 'connect').to_sym, r.pattern, r.options_map)
#      end
#    end

    match "/", :to=>"cms/content#show"
    match "*path", :to=>"cms/content#show"
  end

end
