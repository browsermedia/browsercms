module Cms
  module Behaviors
    module Tagging
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods      
        def taggable?
          !!@is_taggable
        end
        def is_taggable(options={})
          @is_taggable = true
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