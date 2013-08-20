module Cms::RouteExtensions


  # Adds all necessary routes to manage a new content type. Works very similar to the Rails _resources_ method, adding basic CRUD routes, as well as additional ones
  #   for CMS specific routes (like versioning)
  #
  # @param [Symbol] content_block_name - The plural name of a new Content Type. Should match the name of the content_block, like :dogs or :donation_statuses
  def content_blocks(content_block_name, options={}, & block)
    content_name = content_block_name.to_s.classify
    begin
      content_block = "#{Cms::Module.current_namespace}::#{content_name}".constantize
    rescue NameError
      content_block = content_name.constantize
    end

    resources content_block_name do
      member do
        put :publish if content_block.publishable?
        get :versions if content_block.versioned?
        get :usages if content_block.connectable?
      end
    end

    if content_block.versioned?
      send("get", "/#{content_block_name}/:id/version/:version", :to => "#{content_block_name}#version", :as => "version_cms_#{content_block_name}".to_sym)
      send("put", "/#{content_block_name}/:id/revert_to/:version", :to => "#{content_block_name}#revert_to", :as => "revert_to_cms_#{content_block_name}".to_sym)
    end
  end

  # Adds the routes required for BrowserCMS to function to a routes.rb file. Should be the last route in the file, as
  # all following routes will be ignored.
  #
  # Usage:
  #   YourAppName::Application.routes.draw do
  #      match '/some/path/in/your/app' :to=>"controller#action''
  #      mount_browsercms
  #   end
  #
  def mount_browsercms
    mount Cms::Engine => "/cms", :as => "cms"

    add_routes_for_addressable_content_blocks
    add_page_routes_defined_in_database

    # Handle 'stock' attachments
    get "/attachments/:id/:filename", :to => "cms/attachments#download"
    get "/", :to => "cms/content#show"

    # Only need :POST to support  portlets that are acting like controllers.
    # Ideally we could get rid of this need.
    match "*path", :to => "cms/content#show", via: [:get, :post]
  end

  # Preserving for backwards compatibility with bcms-3.3.x and earlier.
  # @deprecated
  alias :routes_for_browser_cms :mount_browsercms

  private

  # Creates a default GET route for every addressable content block class.
  # This will be use a :slug and the module path, like:
  #   /products/:slug
  def add_routes_for_addressable_content_blocks
    classes = Cms::Concerns::Addressable.classes_that_require_custom_routes
    classes.each do |klass|
      path = "#{klass.path}/:slug"
      controller_name = klass.name.demodulize.pluralize.underscore
      get path, to: "cms/#{controller_name}#show_via_slug"
      route_name = "inline_cms_#{klass.name.demodulize.underscore}"
      unless route_exists?(route_name)
        get "cms/#{klass.path}/:id/inline", to: "cms/#{controller_name}#inline", as: route_name
      end

    end

  end

  # Determine if a named route already exists, since Rails 4 will object if a duplicate named route is defined now.
  # Otherwise in development, when routes are reloaded the CMS would throw errors.
  def route_exists?(route_name)
    Rails.application.routes.named_routes[route_name]
  end

  def add_page_routes_defined_in_database
    if Cms::PageRoute.can_be_loaded?
      Cms::PageRoute.order("#{Cms::PageRoute.table_name}.name").each do |r|
        match r.pattern, :to => r.to, :as => r.route_name, :_page_route_id => r.page_route_id, :via => r.via, :constraints => r.constraints
      end
    end
  end
end
