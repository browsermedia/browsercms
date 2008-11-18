require 'browser_cms'
Cms.add_to_rails_paths(Cms.root)

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