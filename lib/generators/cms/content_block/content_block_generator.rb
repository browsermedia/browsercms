require 'rails/generators/migration'
require 'rails/generators/resource_helpers'

module Cms
  module Generators
    # Allows developers to create new Content Blocks for their projects.
    class ContentBlockGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      include Rails::Generators::Migration
      include Rails::Generators::ResourceHelpers

      def set_classpath
        @in_core_application = false
        unless namespaced?
          cms_engine_module_name = Cms::EngineAware.module_name(Rails.application.class).constantize
          Rails::Generators.namespace = cms_engine_module_name
          @in_core_application = true
        end
      end

      def generate_controller
        application_controller = File.join('app/controllers', class_path, "application_controller.rb")
        unless File.exists?(application_controller)
          template 'application_controller.rb.erb', application_controller
        end
      end

      hook_for :orm, :in => :rails, :required => true, :as => :model

      def alter_the_model
        model_file = File.join('app/models', class_path, "#{file_name}.rb")
        spaces = namespaced? ? 4 : 2
        insert_into_file model_file, indent("acts_as_content_block\n", spaces), :after => "ActiveRecord::Base\n"
        insert_into_file model_file, indent("content_module :#{file_name.pluralize}\n", spaces), :after => "acts_as_content_block\n"
      end

      def alter_the_migration
        migration = self.class.migration_exists?(File.absolute_path("db/migrate"), "create_#{table_name}")

        if @in_core_application
          gsub_file migration, "create_table :#{table_name}", "create_table :#{unnamespaced_table_name}"
        end

        gsub_file migration, "create_table", "create_content_table"


        # Attachments do not require a FK from this model to attachments.
        self.attributes.select { |attr| attr.type == :attachment }.each do |attribute|
          gsub_file migration, "t.attachment :#{attribute.name}", ""
        end
        self.attributes.select { |attr| attr.type == :attachments }.each do |attribute|
          gsub_file migration, "t.attachments :#{attribute.name}", ""
        end
        self.attributes.select { |attr| attr.type == :category }.each do
          gsub_file migration, "t.category", "t.belongs_to"
        end
        self.attributes.select { |attr| attr.type == :html }.each do |attribute|
          gsub_file migration, "t.html :#{attribute.name}", "t.text :#{attribute.name}, :size => (64.kilobytes + 1)"
        end
      end

      hook_for :resource_controller, :in => :rails, :as => :controller, :required => true do |instance, controller|
        instance.invoke controller, [instance.name.pluralize]
      end


      def create_controller_and_views
        gsub_file File.join('app/controllers', class_path, "#{file_name.pluralize}_controller.rb"), /ApplicationController/, "Cms::ContentBlockController"
        template '_form.html.erb', File.join('app/views', class_path, file_name.pluralize, "_form.html.erb")
        template 'render.html.erb', File.join('app/views', class_path, file_name.pluralize, "render.html.erb")
      end

      def create_routes
        if namespaced? && !@in_core_application
          route "content_blocks :#{file_name.pluralize}"
        else
          route "namespace :#{namespace.name.underscore} do content_blocks :#{file_name.pluralize} end"
        end
      end

      private

      # @override NamedBase#table_name Copy&Paste of this method to make sure project table names are not actually namespaced in migrations.
      def unnamespaced_table_name
        @unnamespaced_table_name ||= begin
          base = pluralize_table_names? ? plural_name : singular_name
          (regular_class_path + [base]).join('_')
        end
      end

      def model_has_attachment?
        !attachment_attributes().empty?
      end

      def attachment_attributes
        self.attributes.select { |attr| attr.type == :attachment }
      end
    end
  end
end
