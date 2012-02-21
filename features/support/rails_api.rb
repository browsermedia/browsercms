module Cms
  module RailsApi
    def create_rails_project(name)
      run_simple "rails new #{name} --skip-bundle"
    end
  end
end
World(Cms::RailsApi)
