require 'rails/generators/active_record/migration'

module Cms
  module Generators
    # Allows developers to create new Content Blocks for their projects.
    #
    class ContentBlockGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :migration, :type => :boolean, :default=>true

      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      # Don't check for class collision as overwriting content blocks is fine.
      # check_class_collision

      def create_content_block
        template 'content_block.rb', File.join('app/models', "#{file_name}.rb")
      end

      def create_model_test
        template 'unit_test.erb', File.join('test', 'unit', 'models', "#{file_name}_test.rb")
      end

      def create_controller_and_views
        template 'controller.rb', File.join('app/controllers/cms', "#{file_name.pluralize}_controller.rb")
        template '_form.html.erb', File.join('app/views/cms/', file_name.pluralize, "_form.html.erb")
        template 'render.html.erb', File.join('app/views/cms/', file_name.pluralize, "render.html.erb")
      end

      def create_functional_test
        template 'functional_test.erb', File.join('test/functional/cms/', "#{file_name.pluralize}_controller_test.rb")
      end

      def create_routes
        route "namespace :cms  do content_blocks :#{file_name.pluralize} end\n"
      end

      def create_migration_file
        return unless options[:migration]
        migration_template "migration.erb", "db/migrate/create_#{table_name}.rb"
      end

      private

      # Used by migration.rb to fill in class name.
      def migration_name
        "Create#{class_name.pluralize.gsub(/::/, '')}"
      end

    end
  end
end
