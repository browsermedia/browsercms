module Cms
  module Acts
    module ContentObject

      def self.included(cls)
        cls.extend MacroMethods
      end

      module MacroMethods

        STATUSES = {"IN_PROGRESS" => :in_progress, "PUBLISHED" => :publish, "ARCHIVED" => :archive, "DELETED" => :mark_as_deleted}

        def acts_as_content_block(options={})
          @statuses = STATUSES.dup
          acts_as_content_object(options)
          include Cms::BlockSupport
        end

        def acts_as_content_page(options={})
          @statuses = STATUSES.dup
          @statuses["HIDDEN"] = :hide
          acts_as_content_object(options)
        end

        private
        def acts_as_content_object(options={})
          unless options[:versioning] == false
            version_fu
          end

          @default_status = "IN_PROGRESS"
          before_validation_on_create :set_default_status

          validates_inclusion_of :status, :in => @statuses.keys

          define_status_query_methods
          define_status_action_methods

          include InstanceMethods
        end

        def define_status_query_methods
          @statuses.keys.each do |status|
            define_method "#{status.underscore}?" do
              self.status == status
            end
          end
        end

        def define_status_action_methods
          @statuses.each do |status, method_name|
            define_method method_name do
              self.status = status
              save
            end
            define_method "#{method_name}!" do
              self.status = status
              save!
            end
          end
        end
      end

#      module DeleteableMethods
#        def self.included(cls)
#          cls.extend DeleteableClassMethods
#          cls.class_eval do
#            class << self
##              alias_method :core_find,    :find
##              alias_method :find,    :find_not_deleted
#              alias_method :find_with_deleted, :find
#            end
#          end
#          alias_method :destroy!, :destroy
#        end
#
#        def deleted?
#          status == "DELETED"
#        end
#
#        def destroy
#          self.status = "DELETED"
#          save
#        end
#
#        module DeleteableClassMethods
#
#          def find(*args)
#            logger.warn "Calling find"
#            not_deleted.find_with_deleted(*args)
#
#          end
##          def find_with_deleted(*args)
##            find(*args)
##          end
##
##          def find_with_deleted(*args)
##            core_find(*args)
##          end
#        end
#      end

      # These methods will be added to any object marked as acts_as_content_object or acts_as_content_page
      module InstanceMethods

        def self.included(cls)
          cls.extend ClassMethods
        end

        def set_default_status
          self.status = self.class.default_status if status.blank?
        end

        def status_name
          status.titleize
        end

        module ClassMethods
          def default_status
            @default_status
          end
          def statuses
            @statuses
          end
        end

      end
    end
  end
end