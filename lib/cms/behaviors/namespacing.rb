module Cms
  module Behaviors
    module Namespacing
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        def namespaces_table
          extend ClassMethods
          include InstanceMethods
          set_table_name "#{namespace.underscore}_#{base_class.table_name}"
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
