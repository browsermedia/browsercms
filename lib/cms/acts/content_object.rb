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
          if options[:versioning] == false
            #has_many :connectors, :conditions => 'content_block_id = #{id} and content_block_type = #{self.class}', :order => "position"          
            has_many :connectors, :order => "position"          
          else
            after_update :update_page_version
            #has_many :connectors, :conditions => 'content_block_id = #{id} and content_block_type = #{self.class} and content_block_version = #{version}', :order => "position"          
            has_many :connectors, :foreign_key => 'content_block_id', :conditions => 'content_block_type = \'#{self.class}\' and content_block_version = #{version}', :order => "position"          
          end          
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
            
            #We set the value of the the association to the value in the virtual attriute
            #This makes sute that updated_by_user is explictly set on each update
            versioned_class.belongs_to :updated_by, :class_name => "User"
            attr_accessor :updated_by_user
            belongs_to :updated_by, :class_name => "User"
            before_validation :set_updated_by
            
            validates_presence_of :updated_by_id            
            
          end
          is_paranoid

          attr_accessor :new_status
          before_validation :reset_status

          @default_status = "IN_PROGRESS"
          after_destroy :destroy_versions_if_destroyed

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
          alias_method :live?, :published?
        end

        def define_status_action_methods
          @statuses.each do |status, method_name|
            define_method method_name do |updated_by|
              self.new_status = status
              self.updated_by_user = updated_by
              save
            end
            define_method "#{method_name}!" do |updated_by|
              self.new_status = status
              self.updated_by_user = updated_by
              save!
            end
          end
        end
      end

      # These methods will be added to any object marked as acts_as_content_object or acts_as_content_page
      module InstanceMethods
        def supports_versioning?
          self.respond_to?(:versions)
        end

        def self.included(cls)
          cls.extend ClassMethods
        end

        def reset_status
          self.status = new_status || self.class.default_status
          self.new_status = nil
          status
        end

        def status_name
          status.titleize
        end

        def destroy_versions_if_destroyed
          return unless supports_versioning?
          self.class.versioned_class.delete_all("#{self.class.versioned_foreign_key} = #{id}") if destroyed?
        end

        def set_updated_by
          self.updated_by = updated_by_user
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