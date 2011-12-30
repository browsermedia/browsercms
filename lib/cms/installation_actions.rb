module Cms
  module InstallationActions

    def default_engine_path(module_name, path=nil)
      "/#{module_name.name.underscore}"
    end
  end
end