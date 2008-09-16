ActiveRecord::Migrator.add_path File.join(File.dirname(__FILE__), "..", "db", "migrate")
Dependencies.load_paths += [
  File.join(File.dirname(__FILE__), "..", "app", "controllers"),
  File.join(File.dirname(__FILE__), "..", "app", "helpers"),
  File.join(File.dirname(__FILE__), "..", "app", "models")
]
Rails.configuration.controller_paths << File.join(File.dirname(__FILE__), "..", "app", "controllers")
ActionController::Base.append_view_path File.join(File.dirname(__FILE__), "..", "app", "views")

cms_routes = open(File.join(File.dirname(__FILE__), "routes.rb")){|f| f.read }
ActionController::Routing::RouteSet.send(:define_method, :load_routes!) do
  if configuration_file
    load configuration_file
    ActionController::Routing::RouteSet::Mapper.new(self).instance_eval(cms_routes)
    @routes_last_modified = File.stat(configuration_file).mtime
  else
    add_route ":controller/:action/:id"
  end
end