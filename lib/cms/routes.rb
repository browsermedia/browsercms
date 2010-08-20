module Cms::Routes

  #
  # content_block_name - Should be a plural symbol matching the name of the content_block, like :dogs or :donation_statuses
  #
  def content_blocks(content_block_name, options={}, & block)
    content_block = content_block_name.to_s.classify.constantize
    resources(* [content_block_name, default_routes_for_content_block(content_block).deep_merge(options)], & block)
    if content_block.versioned?
      send("get", "/cms/#{content_block_name}/:id/version/:version", :to=>"cms/#{content_block_name}#version", :as=>"version_cms_#{content_block_name}".to_sym)
      send("put", "/cms/#{content_block_name}/:id/revert_to/:version", :to=>"cms/#{content_block_name}#revert_to", :as=>"revert_to_cms_#{content_block_name}".to_sym)
    end
  end

  def default_routes_for_content_block(content_block)
    member_routes = {}
    member_routes[:publish] = :put if content_block.publishable?
    member_routes[:versions] = :get if content_block.versioned?
    member_routes[:usages] = :get if content_block.connectable?
    {:member => member_routes}
  end

  #
  def routes_for_browser_cms

    namespace :cms do
      # Namespaces don't seem to 'prefix' controller names for non-resource methods
      # The Rails 3 release may avoid the need for explicitly prefixing cms/ to all these methods
      match '/dashboard', :to=>"cms/dashboard#index", :as=>'dashboard'
      # I want to do the following instead
      # match '/dashboard', :to=>"dashboard#index", :as=>'dashboard'

      match '/', :to => 'cms/home#index', :as=>'home'
      match '/sitemap', :to=>"cms/section_nodes#index", :as=>'sitemap'
      match '/content_library', :to=>"cms/html_blocks#index", :as=>'content_library'
      match '/administration', :to=>"cms/users#index", :as=>'administration'
      match '/logout', :to=>"cms/sessions#destroy", :as=>'logout'
      get '/login', :to=>"cms/sessions#new", :as=>'login'
      post '/login', :to=>"cms/sessions#create"

      match '/toolbar', :to=>"cms/toolbar#index", :as=>'toolbar'
      match '/content_types', :to=>"cms/content_types#index", :as=>'content_types'

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
      get '/cms/pages/:id/version/:version', :to=>'cms/pages#version', :as=>'version_cms_page'
      put '/cms/pages/:id/revert_to/:version', :to=>'cms/pages#revert_to', :as=>'revert_to_cms_page'
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
      resources :page_partials, :controller => 'cms/dynamic_views'
      resources :page_templates, :controller => 'cms/dynamic_views'
      resources :page_routes do
        resources :conditions, :controller => "cms/page_route_conditions"
        resources :requirements, :controller => "cms/page_route_requirements"
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
