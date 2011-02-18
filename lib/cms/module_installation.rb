# Provides a base class for Module installation generators.
#
# This strategy assumes that modules will subclass this, and copy files from their db/migrate directory.
# Usage:
#
#   require 'cms/module_installation'
#   class MyModule::InstallGenerator < Cms::ModuleInstallation
#     add_migrations_directory_to_source_root __FILE__
#     copy_migration_file 'DATE_STAMP_create_some_block_name.rb'
#   end
#
class Cms::ModuleInstallation < Rails::Generators::Base

  # This will be relative to the gem
  # e.g. add_migrations_directory_to_source_root __FILE__
  def self.add_migrations_directory_to_source_root(generator_file_object)
    source_root File.expand_path('../../../../../db/migrate/', generator_file_object)
  end

  # Add a migration file to the list of files to be copied from this gem into the project.
  def self.copy_migration_file(name_of_file)
    @migration_files = [] unless @migration_files
    @migration_files << name_of_file
  end

  def self.migration_files
    @migration_files
  end

  def copy_migrations_to_project
    if self.class.migration_files
      self.class.migration_files.each do |file_name|
        copy_file file_name, "db/migrate/#{file_name}"
      end
    end
  end

end