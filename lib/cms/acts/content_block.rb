module Cms
  module Acts
    module ContentBlock
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        def acts_as_content_block(options={})
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
            "#{self.class.name.titleize} '#{name}'"
          end
        end
      end
    end
  end
end