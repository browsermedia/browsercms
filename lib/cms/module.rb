puts 'load module'
module Cms


  module Module

    def self.included(base)
      # Make sure class in app/portlets are in the load_path
      portlets_dir = File.join("..", "..", "app", "portlets")
      base.config.autoload_paths << portlets_dir

      # All modules should copy their own migrations into the main project.
      Cms.add_paths_to_copied_into_project(Engine.root, "db/migrate/[0-9]*_*.rb")
    end

  end
end