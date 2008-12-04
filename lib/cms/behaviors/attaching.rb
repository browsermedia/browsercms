module Cms
  module Behaviors
    module Attaching
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods      
        def belongs_to_attachment?
          !!@belongs_to_attachment
        end
        def belongs_to_attachment
          @belongs_to_attachment = true
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