module Cms
  module Acts
    module Paranoid
      def is_paranoid
        named_scope :not_deleted, :conditions => ["deleted = ?", false]
        class << self
          alias_method :find_with_deleted, :find
          alias_method :count_with_deleted, :count
        end
        alias_method :destroy_without_callbacks!, :destroy_without_callbacks
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    module ClassMethods
      def find(*args)
        not_deleted.find_with_deleted(*args)
      end
      def count(*args)
        not_deleted.count_with_deleted(*args)
      end
      alias_method :original_method_missing, :method_missing
      def method_missing(method_id, *arguments)
        if matches_dynamic_finder?(method_id) || matches_dynamic_finder_with_initialize_or_create?(method_id)
          raise "Dynamic Finders are not currently supported by paranoid"
        else
          original_method_missing(method_id, *arguments)
        end
      end      
    end

    module InstanceMethods
      #Overrides original destroy method
      def destroy_without_callbacks
        update_attribute(:deleted, true)
      end

      def destroy_with_callbacks!
        return false if callback(:before_destroy) == false
        result = destroy_without_callbacks!
        @destroyed = true
        callback(:after_destroy)
        result
      end

      def destroy!
        transaction { destroy_with_callbacks! }
      end
      
      def destroyed?
        @destroyed
      end
            
    end
  end
end

