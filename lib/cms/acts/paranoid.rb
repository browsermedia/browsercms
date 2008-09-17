module Cms
  module Acts
    module Paranoid
      def is_paranoid
        named_scope :not_deleted, :conditions => ["(status != ? OR status is null)", "DELETED"]
        class << self
          alias_method :find_with_deleted, :find
        end
        alias_method :destroy!, :destroy
        extend ClassMethods
        include InstanceMethods
      end
    end
    module ClassMethods
      def find(*args)
        not_deleted.find_with_deleted(*args)
      end

      # This could be more efficent
      #      def exists?(*args)
      #        not_deleted.find_with_deleted(*args).size > 0
      #      end
    end
    module InstanceMethods
      def destroy
        update_attribute(:status, "DELETED")
      end

      def deleted?
        status == "DELETED"
      end
    end
  end
end

