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
    
    # Allows additional menu items to be added to the 'Tools' menu on the Admin tab.
    config.cms.tools_menu = ActiveSupport::OrderedOptions.new

    # Define configuration for the CKEditor
    config.cms.ckeditor = ActiveSupport::OrderedOptions.new
    
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

    # Set reasonable defaults
    # These default values can be changed by developers in their projects in their application.rb or environment's files.
    config.before_configuration do |app|

      # Default cache directories.
      app.config.cms.mobile_cache_directory = File.join(Rails.root, 'public', 'cache', 'mobile')
      app.config.cms.page_cache_directory = File.join(Rails.root, 'public', 'cache', 'full')

      # Default storage for uploaded files
      app.config.cms.attachments.storage = :filesystem
      app.config.cms.attachments.storage_directory = File.join(Rails.root, 'tmp', 'uploads')

      # Determines if a single domain will be used (i.e. www) or multiple subdomains (www and cms). Enabling this will
      # turn off page caching and not handle redirects between subdomains.
      app.config.cms.use_single_domain = false

      # Used to send emails with links back to the Cms Admin. In production, this should include the www. of the public site.
      # Matters less in development, as emails generally aren't sent.
      # I.e.
      #   config.cms.site_domain = "www.browsercms.org"
      app.config.cms.site_domain = "localhost:3000"
      
      # Determines which ckeditor file will be used to configure all instances.
      # There should be at most ONE of these, so use manifest files which require the below one to augement it.
      app.config.cms.ckeditor.configuration_file = 'bcms/ckeditor_standard_config.js'
      
      # Define menu items to be added dynamically to the CMS Admin tab.
      app.config.cms.tools_menu = []
    end

    initializer 'browsercms.add_core_routes', :after => 'action_dispatch.prepare_dispatcher' do |app|
      ActionDispatch::Routing::Mapper.send :include, Cms::RouteExtensions
    end

    initializer 'browsercms.add_load_paths', :after => 'action_controller.deprecated_routes' do |app|
      ActiveSupport::Dependencies.autoload_paths += %W( #{self.root}/vendor #{self.root}/app/mailers #{self.root}/app/helpers)
      ActiveSupport::Dependencies.autoload_paths += %W( #{self.root}/app/controllers #{self.root}/app/models #{self.root}/app/portlets)
      ActiveSupport::Dependencies.autoload_paths += %W( #{Rails.root}/app/portlets )
      ActiveSupport::Dependencies.autoload_paths += %W( #{Rails.root}/app/portlets/helpers )
      ActionController::Base.append_view_path DynamicView.base_path
      ActionController::Base.append_view_path %W( #{self.root}/app/views)
      ActionView::Base.default_form_builder = Cms::FormBuilder
      require 'jdbc_adapter' if defined?(JRUBY_VERSION)
    end

    initializer "browsercms.precompile_assets" do |app|
      app.config.assets.precompile += ['cms/application.css']
    end

  end
end