module Cms
  module Acts
    module Paranoid
      def is_paranoid
        named_scope :not_deleted, :conditions => ["(status != ? OR status is null)", "DELETED"]
        class << self
          alias_method :find_with_deleted, :find
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
    end

    module InstanceMethods
      #Overrides original destroy method
      def destroy_without_callbacks
        update_attribute(:status, "DELETED")
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

      def deleted?
        status == "DELETED"
      end
      
      def destroyed?
        @destroyed
      end
    end
  end
end

