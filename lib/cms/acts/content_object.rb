module Cms
  module Acts
    module ContentObject

      def self.included(cls)
        cls.extend MacroMethods
      end

      module MacroMethods
        DELETED = "DELETED"
        STATUSES = {"IN_PROGRESS" => :in_progress, "PUBLISHED" => :publish, "ARCHIVED" => :archive, DELETED => :mark_as_deleted}

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
          is_paranoid
          
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