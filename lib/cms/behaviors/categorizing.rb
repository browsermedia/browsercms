module Cms
  module Behaviors
    module Categorizing
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods      
        def belongs_to_category?
          !!@belongs_to_category
        end
        def belongs_to_category
          @belongs_to_category = true
          extend ClassMethods
          include InstanceMethods
        end
        module ClassMethods
        end
        module InstanceMethods
        end
      end
    end
  end
end