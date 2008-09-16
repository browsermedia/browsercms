require 'cms'
ActiveRecord::Migrator.add_path File.join(Cms.root, "db", "migrate")
Dependencies.load_paths += [
  File.join(Cms.root, "app", "controllers"),
  File.join(Cms.root, "app", "helpers"),
  File.join(Cms.root, "app", "models")
]
Rails.configuration.controller_paths << File.join(Cms.root, "app", "controllers")
ActionController::Base.append_view_path File.join(Cms.root, "app", "views")

cms_routes = open(File.join(Cms.root, "rails/routes.rb")){|f| f.read }
ActionController::Routing::RouteSet.send(:define_method, :load_routes!) do
  if configuration_file
    load configuration_file
    ActionController::Routing::RouteSet::Mapper.new(self).instance_eval(cms_routes)
    @routes_last_modified = File.stat(configuration_file).mtime
  else
    add_route ":controller/:action/:id"
  end
end

Cms.init