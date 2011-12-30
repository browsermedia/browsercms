require 'cms/installation_actions'

# Provides a base class for Module installation generators.
#
# Usage:
#
#   require 'cms/module_installation'
#   class MyModule::InstallGenerator < Cms::ModuleInstallation
#     add_migrations_directory_to_source_root __FILE__
#   end
#
class Cms::ModuleInstallation < Rails::Generators::Base
  include Cms::InstallationActions

  # This will be relative to the gem
  # e.g. add_migrations_directory_to_source_root __FILE__
  def self.add_migrations_directory_to_source_root(generator_file_object)
    source_root File.expand_path('../../../../../db/migrate/', generator_file_object)
  end

  protected

  # Adds a typical route for a Engine to a project.
  #
  # @param [String] module_name i.e. BcmsWhatever
  # @param [String] path i.e. /bcms_whatever (Optional - Will be generated based off the module if not specified)
  def mount_engine(module_name, path_name=nil)
    path_name = default_engine_path(module_name) unless path_name
    route "mount #{module_name}::Engine => '#{path_name}'"
  end
end