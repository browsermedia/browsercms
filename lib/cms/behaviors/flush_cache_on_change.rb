module Cms
  module Behaviors
    module FlushCacheOnChange
      def self.included(model_class)
        model_class.extend(MacroMethods)
        model_class.class_eval do
          def flush_cache_on_change?
            false
          end
        end
      end
      module MacroMethods      
        def flush_cache_on_change?
          !!@flush_cache_on_change
        end
        def flush_cache_on_change(options={})
          include InstanceMethods
          @flush_cache_on_change = true
          
          after_save :flush_cache
          after_destroy :flush_cache
        end
      end
      module InstanceMethods
        def flush_cache
          Cms::Cache.flush
        end
      end
    end
  end
end