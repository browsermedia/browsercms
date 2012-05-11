require 'rails'
require 'cms/module'
require 'cms/configuration'
require 'cms/version'
require 'browsercms'

# Gem name is different than file name
# Must be required FIRST, so that our assets paths appear before its do.
# This allows app/assets/ckeditor/config.js to set CMS specific defaults.
require 'ckeditor-rails'

# Explicitly require this, so that CMS projects do not need to add it to their Gemfile
# especially while upgrading
require 'jquery-rails'

module Cms

  class Engine < Rails::Engine
    include Cms::Module
    isolate_namespace Cms

    config.cms = ActiveSupport::OrderedOptions.new
    config.cms.attachments = ActiveSupport::OrderedOptions.new

    # Make sure we use our rails model template (rather then its default) when `rails g cms:content_block` is run.
    config.app_generators do |g|
      path = File::expand_path('../../templates', __FILE__)
      g.templates.unshift path
    end

    # Ensure Attachments are configured:
    # 1. Before every request in development mode
    # 2. Once in production
    config.to_prepare do
      Attachments.configure
    end

    # We want the default cache directories to be overridable in the application.rb, so set them early in the boot process.
    config.before_configuration do |app|
      app.config.cms.mobile_cache_directory = File.join(Rails.root, 'public', 'cache', 'mobile')
      app.config.cms.page_cache_directory = File.join(Rails.root, 'public', 'cache', 'full')

      app.config.cms.attachments.storage = :filesystem
      app.config.cms.attachments.storage_directory = File.join(Rails.root, 'tmp', 'uploads')
    end

    initializer 'browsercms.add_core_routes', :after => 'action_dispatch.prepare_dispatcher' do |app|
      ActionDispatch::Routing::Mapper.send :include, Cms::RouteExtensions
    end

    initializer 'browsercms.add_load_paths', :after => 'action_controller.deprecated_routes' do |app|
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