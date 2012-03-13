require 'rails'
require 'cms/module'
require 'cms/init'
require 'browsercms'

# Gem name is different than file name
# Must be required FIRST, so that our assets paths appear before its do.
# This allows app/assets/ckeditor/config.js to set CMS specific defaults.
require 'ckeditor-rails'

module Cms

  # Configuring BrowserCMS as an engine. This seems to work, but could probably be cleaned up.
  #
  class Engine < Rails::Engine
    include Cms::Module
    isolate_namespace Cms


    # Make sure we use our rails model template
    config.app_generators do |g|
      path = File::expand_path('../../templates', __FILE__)
      g.templates.unshift path
    end

    Cms.add_generator_paths(Cms.root,
                            "public/site/**/*",
                            "db/seeds.rb")

    initializer 'browsercms.add_core_routes', :after => 'action_dispatch.prepare_dispatcher' do |app|
      Rails.logger.debug "Adding Cms::Routes to ActionDispatch"
      ActionDispatch::Routing::Mapper.send :include, Cms::RouteExtensions
    end

    initializer 'browsercms.add_load_paths', :after => 'action_controller.deprecated_routes' do |app|
      Rails.logger.debug "Add Cms::Dependencies and other load_path configurations."
      ::Cms::Engine.add_cms_load_paths
    end

    initializer "browsercms.precompile_assets" do |app|
      app.config.assets.precompile += ['cms/application.css']
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