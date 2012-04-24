require 'rails/generators/active_record/migration'
require 'rails/generators/resource_helpers'

module Cms
  module Generators
    # Allows developers to create new Content Blocks for their projects.
    class ContentBlockGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      include Rails::Generators::Migration
      include Rails::Generators::ResourceHelpers

      hook_for :orm, :in => :rails, :required => true, :as => :model

      def alter_the_model
        model_file = File.join('app/models', class_path, "#{file_name}.rb")
        spaces = namespaced? ? 4 : 2
        insert_into_file model_file, indent("acts_as_content_block\n", spaces), :after => "ActiveRecord::Base\n"
      end

      def alter_the_migration
        migration = self.class.migration_exists?(File.absolute_path("db/migrate"), "create_#{table_name}")
        gsub_file migration, "create_table", "create_content_table"
        insert_into_file migration, :after => "def change\n" do
          <<-RUBY
    Cms::ContentType.create!(:name => "#{class_name}", :group_name => "#{group_name}")
          RUBY
        end

        # Attachments do not require a FK from this model to attachments.
        self.attributes.select { |attr| attr.type == :attachment }.each do |attribute|
          gsub_file migration, "t.attachment :#{attribute.name}", ""
        end
        self.attributes.select { |attr| attr.type == :attachments }.each do |attribute|
          gsub_file migration, "t.attachments :#{attribute.name}", ""
        end
        unless class_name.starts_with?("Cms::")
          gsub_file migration, " do |t|", ", :prefix=>false do |t|"
        end
        self.attributes.select { |attr| attr.type == :category }.each do
          gsub_file migration, "t.category", "t.belongs_to"
        end
        self.attributes.select { |attr| attr.type == :html }.each do |attribute|
          gsub_file migration, "t.html :#{attribute.name}", "t.text :#{attribute.name}, :size => (64.kilobytes + 1)"
        end
      end

      hook_for :resource_controller, :in => :rails, :as => :controller, :required => true do |controller|
        invoke controller, [namespaced_controller_name, options[:actions]]
      end

      def create_controller_and_views
        gsub_file File.join('app/controllers', cms_or_class_path, "#{file_name.pluralize}_controller.rb"), /ApplicationController/, "Cms::ContentBlockController"
        template '_form.html.erb', File.join('app/views', cms_or_class_path, file_name.pluralize, "_form.html.erb")
        template 'render.html.erb', File.join('app/views', cms_or_class_path, file_name.pluralize, "render.html.erb")
      end

      def create_routes
        if namespaced?
          route "content_blocks :#{file_name.pluralize}"
        else
          route "namespace :cms  do content_blocks :#{file_name.pluralize} end"
        end
      end

      private

      def model_has_attachment?
        !attachment_attributes().empty?
      end

      def attachment_attributes
        self.attributes.select { |attr| attr.type == :attachment }
      end


      def group_name
        if namespaced?
          class_name.split("::").first
        else
          class_name
        end
      end

      def namespaced_controller_name
        unless namespaced?
          "cms/#{@controller_name}"
        else
          @controller_name
        end
      end

      # Modules want to put classes under their namespace folders, i.e
      #   - app/controllers/bcms_widgets/widget_controller
      #
      # while projects want to put it under cms
      #   - app/controllers/cms/widget_controller
      def cms_or_class_path
        if namespaced?
          class_path
        else
          ["cms"]
        end
      end
    end
  end
end
