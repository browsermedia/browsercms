module Cms
  module Behaviors
    module Namespacing
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        
        def namespaced_table?
          !!@namespaced_table
        end
        
        def namespaces_table
          extend ClassMethods
          include InstanceMethods

          unless @namespaced_table
            set_table_name "#{ self.to_s.split("::")[0...-1].map(&:underscore).join("_").downcase}_#{base_class.table_name}"
          end
          @namespaced_table = true
        end
      end
      module ClassMethods
      end
      module InstanceMethods
        def table_name
          self.class.table_name
        end
      end
    end
  end
end
