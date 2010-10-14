module Cms
  module Behaviors
    module SoftDeleting
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods      
        def uses_soft_delete?
          !!@uses_soft_delete
        end
        def uses_soft_delete(options={})
          @uses_soft_delete = true
        
          scope :not_deleted, :conditions => ["#{table_name}.deleted = ?", false]
          class << self
#            alias_method :find_with_deleted, :find
            alias_method :count_with_deleted, :count
            alias_method :delete_all!, :delete_all
          end

          extend ClassMethods
          include InstanceMethods

#          alias_method :destroy_without_callbacks!, :destroy_without_callbacks

          # By default, all queries for blocks should filter out deleted rows.
          default_scope where(:deleted => false)

        end
      end
      module ClassMethods

        def find_with_deleted(*args)
          self.with_exclusive_scope { find(*args) }
        end

#        def find(*args)
#          not_deleted.find_with_deleted(*args)
#        end
        def count(*args)
          not_deleted.count_with_deleted(*args)
        end
        def delete_all(conditions=nil)
          update_all(["deleted = ?", true], conditions)
        end
        def exists?(id_or_conditions)
          if id_or_conditions.is_a?(Hash) || id_or_conditions.is_a?(Array)
            conditions = {:conditions => id_or_conditions}
          else
            conditions = {:conditions => {:id => id_or_conditions}}
          end
          count(conditions) > 0
        end
      end
      module InstanceMethods

        # Destroying a soft deletable model should mark the record as deleted, and not actually remove it from the database.
        #
        # Overrides original destroy method
        def destroy
          if self.class.publishable?
            update_attributes(:deleted => true, :publish_on_save => true)
          else
            update_attributes(:deleted => true)
          end
        end

        def mark_as_deleted!
          destroy
        end

        def destroy_with_callbacks!
          return false if callback(:before_destroy) == false
          result = destroy_without_callbacks!
          @destroyed = true
          callback(:after_destroy)
          result
        end

        def destroy!
          transaction { super.destroy }
        end

        def destroyed?
          @destroyed
        end        
      end
    end
  end
end
