module Cms
  module Acts
    module ContentBlock

      class NilModel
        def initialize(table_name)
          @table_name = table_name
        end

        def version_foreign_key
          Cms::Behaviors::Versioning.default_foreign_key(@table_name)
        end

        def to_s
          "NilModel::#{@table_name}"
        end

      end

      def self.model_for(table_name)
        unscoped_table_name = table_name.to_s.gsub(Cms.table_prefix, "")
        class_name = unscoped_table_name.to_s.classify
        return "Cms::#{class_name}".constantize
      rescue NameError
        begin
          return class_name.constantize
        rescue
          return NilModel.new(table_name)
        end
      end

      def self.included(model_class)
        model_class.extend(MacroMethods)
      end

      module MacroMethods

        # Adds Content Block behavior to this class
        #
        # @param [Hash] options
        def acts_as_content_block(options={})
          defaults = {
            # Set default values here.
          }
          options = defaults.merge(options)

          belongs_to_attachment(options[:belongs_to_attachment].is_a?(Hash) ? options[:belongs_to_attachment] : {}) if options[:belongs_to_attachment]
          is_archivable(options[:archiveable].is_a?(Hash) ? options[:archiveable] : {}) unless options[:archiveable] == false
          is_connectable(options[:connectable].is_a?(Hash) ? options[:connectable] : {}) unless options[:connectable] == false
          flush_cache_on_change(options[:flush_cache_on_change].is_a?(Hash) ? options[:flush_cache_on_change] : {}) unless options[:flush_cache_on_change] == false
          is_renderable({:instance_variable_name_for_view => "@content_block"}.merge(options[:renderable].is_a?(Hash) ? options[:renderable] : {})) unless options[:renderable] == false
          is_publishable(options[:publishable].is_a?(Hash) ? options[:publishable] : {}) unless options[:publishable] == false
          is_searchable(options[:searchable].is_a?(Hash) ? options[:searchable] : {}) unless options[:searchable] == false
          uses_soft_delete(options[:soft_delete].is_a?(Hash) ? options[:soft_delete] : {}) unless options[:soft_delete] == false
          is_taggable(options[:taggable].is_a?(Hash) ? options[:taggable] : {}) if options[:taggable]
          is_userstamped(options[:userstamped].is_a?(Hash) ? options[:userstamped] : {}) unless options[:userstamped] == false
          is_versioned(options[:versioned].is_a?(Hash) ? options[:versioned] : {}) unless options[:versioned] == false

          include InstanceMethods
        end

        module InstanceMethods
          def to_s
            "#{self.class.name.demodulize.titleize} '#{name}'"
          end
        end
      end
    end
  end
end
