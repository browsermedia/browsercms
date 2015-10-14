module Cms
  module Behaviors
    module Readonly
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        def readonly?
          !!@is_readonly
        end
        def is_readonly(_options={})
          @is_readonly = true
          include InstanceMethods
        end
      end
      module InstanceMethods
        def readonly?
          true
        end
      end
    end
  end
end
