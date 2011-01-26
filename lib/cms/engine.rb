puts 'loading engine (Cms::Engine)'

require 'rails'
require 'browsercms'

module Cms

  # Configuring BrowserCMS as an engine. This seems to work, but could probably be cleaned up.
  #
  class Engine < Rails::Engine



    initializer 'browsercms.add_core_routes', :after=>'action_dispatch.prepare_dispatcher' do |app|
      puts "Adding Cms::Routes to Dispatch"
      add_cms_routes_method()
    end



    initializer 'browsercms.add_load_paths', :after=>'action_controller.deprecated_routes' do |app|
      puts "Adding load_paths"

      add_cms_load_paths()

    end


    portlets_dir = File.join("..", "..", "app", "portlets")
    puts "Adding portlets dir #{portlets_dir} to the loadpath"
    config.autoload_paths << portlets_dir

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

      puts "Specifiying Cms::FormBuilder"

      ActionView::Base.default_form_builder = Cms::FormBuilder

      puts "Require jruby, if needed"
      require 'jdbc_adapter' if defined?(JRUBY_VERSION)
    end
  end
end