require 'cms/engine_helper'

module Cms

  # All BrowserCMS modules will:
  # 1. Add app/portlets to the loadpath
  # 2. Serve static assets from their public directory.
  module Module

    def self.current_namespace=(ns)
      @ns = ns
    end

    def self.current_namespace
      @ns
    end

    def self.included(base)
      # Make sure class in app/portlets are in the load_path
      portlets_dir = File.join("..", "..", "app", "portlets")
      base.config.autoload_paths << portlets_dir
    end

    # This is a bit of a hack, but we need to store the current namespaces so that module developers can just write:
    #
    # BcmsZoo::Engine.routes.draw do
    #   <tt>content_blocks :bear</tt>
    # end
    #
    # And have it correctly find the right namespaced class model (i.e. BcmsZoo::Bear)
    def routes
      Module.current_namespace = ::Cms::EngineAware.module_name(self.class)
      super
    end
  end
end