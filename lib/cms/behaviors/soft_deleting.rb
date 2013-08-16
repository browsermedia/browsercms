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

        def handle_missing_table_error_during_startup(message, e)
          Rails.logger.debug "#{message}: #{e.inspect}"
        end

        def uses_soft_delete(options={})
          @uses_soft_delete = true

          scope :not_deleted, -> {where (["#{table_name}.deleted = ?", false])}
          class << self
            alias_method :delete_all!, :delete_all
          end

          extend ClassMethods
          include InstanceMethods
         #attr_accessible :deleted

          # By default, all queries for blocks should filter out deleted rows.
          begin
            default_scope {where(:deleted => false)}
          # This may fail during gem loading, if no DB or the table does not exist. Log it and move on.
          rescue StandardError => e
            handle_missing_table_error_during_startup("Can't set a default_scope for soft_deleting", e)
          end
        end
      end

      # TODO: Refactor this class to remove need for overriding count, delete_all, etc.
      # Should not be necessary due to introduction of 'default_scope'.
      #
      # 2. TODO: Allow a record to define its own default_scope that doesn't 'override' this one.
      # See http://github.com/fernandoluizao/acts_as_active for an implementation of this
      module ClassMethods

        # Returns a content block even if it is marked as deleted.
        # @param [Hash] options Hash suitable to be passed to '#where'
        def find_with_deleted(options)
          self.unscoped.where(options).first
        end

        # Returns a count of all records of this type, including those marked as deleted.
        #
        # Behaves like ActiveRecord.count is originally implemented.
        #
        # @param args Same params as ActiveRecord.count
        def count_with_deleted(* args)
          self.unscoped.count(* args)
        end

        def delete_all(conditions=nil)
          where(conditions).update_all(["deleted = ?", true])
        end

        def exists?(id_or_conditions)
          query = if id_or_conditions.is_a?(Hash) || id_or_conditions.is_a?(Array)
            where id_or_conditions
          else
            where(:id => id_or_conditions)
          end
          query.count > 0
        end
      end
      module InstanceMethods

        # Destroying a soft deletable model should mark the record as deleted, and not actually remove it from the database.
        #
        # Overrides original destroy method
        def destroy
          run_callbacks :destroy do
            if self.class.publishable?
              update_attributes(:deleted => true, :publish_on_save => true)
            else
              update_attributes(:deleted => true)
            end
          end
        end

        def mark_as_deleted!
          destroy
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
