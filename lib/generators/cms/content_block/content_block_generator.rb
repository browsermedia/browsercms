require 'rails/generators/active_record/migration'

module Cms
  module Generators
    # Allows developers to create new Content Blocks for their projects.
    class ContentBlockGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      include Rails::Generators::Migration

      # Don't check for class collision as overwriting content blocks is fine.
      # check_class_collision

      hook_for :orm, :in=>:rails, :required=>true, :as=>:model

      def alter_the_model
        insert_into_file "app/models/#{file_name}.rb", :after=>"ActiveRecord::Base\n" do
          "    acts_as_content_block\n"
        end
      end

      def alter_the_migration
        migration = self.class.migration_exists?(File.absolute_path("db/migrate"), "create_#{table_name}")
        gsub_file migration, "create_table", "create_content_table"
        insert_into_file migration, :after=>"def change\n" do
          <<-RUBY
    Cms::ContentType.create!(:name => "#{class_name}", :group_name => "#{class_name}")
          RUBY
        end

        unless class_name.starts_with?("Cms::")
          gsub_file migration, "do", ", :prefix=>false do"
        end
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

      private

      def namespaced_controller_class
        "#{class_name.pluralize}Controller"
      end
    end
  end
end
