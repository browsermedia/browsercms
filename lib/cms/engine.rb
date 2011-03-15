#puts 'load engine'
require 'rails'
require 'cms/module'
require 'cms/init'
require 'browsercms'

module Cms

  # Configuring BrowserCMS as an engine. This seems to work, but could probably be cleaned up.
  #
  class Engine < Rails::Engine
    include Cms::Module

    Cms.add_generator_paths(Cms.root,
                              "public/site/**/*",
                              "db/seeds.rb")

    config.action_view.javascript_expansions[:bcms_core] = ['jquery', 'jquery-ui', 'jquery.cookie.js', 'jquery.selectbox-0.5.js', 'jquery.taglist.js', Cms.wysiwig_js, 'cms/application']

    initializer 'browsercms.add_core_routes', :after=>'action_dispatch.prepare_dispatcher' do |app|
      Rails.logger.debug "Adding Cms::Routes to ActionDispatch"
      ::Cms::Engine.add_cms_routes_method
    end

    initializer 'browsercms.add_load_paths', :after=>'action_controller.deprecated_routes' do |app|
      Rails.logger.debug "Add Cms::Dependencies and other load_path configurations."
      ::Cms::Engine.add_cms_load_paths
    end

    def self.add_cms_routes_method
      ActionDispatch::Routing::Mapper.send :include, Cms::Routes
    end

    def self.add_cms_load_paths
      ActiveSupport::Dependencies.autoload_paths += %W( #{self.root}/vendor #{self.root}/app/mailers #{self.root}/app/helpers)
      ActiveSupport::Dependencies.autoload_paths += %W( #{self.root}/app/controllers #{self.root}/app/models #{self.root}/app/portlets)
      ActiveSupport::Dependencies.autoload_paths += %W( #{Rails.root}/app/portlets )
      ActiveSupport::Dependencies.autoload_paths += %W( #{Rails.root}/app/portlets/helpers )
      ActionController::Base.append_view_path DynamicView.base_path
      ActionController::Base.append_view_path %W( #{self.root}/app/views)

      ActionView::Base.default_form_builder = Cms::FormBuilder
      require 'jdbc_adapter' if defined?(JRUBY_VERSION)
    end
  end
end