module Cms
  module Acts
    module ContentObject

      def self.included(cls)
        cls.extend MacroMethods
      end

      module MacroMethods

        def acts_as_content_block(options={})
          acts_as_content_object(options)
          include Cms::BlockSupport
          if options[:versioning] == false
            #has_many :connectors, :conditions => 'content_block_id = #{id} and content_block_type = #{self.class}', :order => "position"          
            has_many :connectors, :as => :content_block, :order => "position"          
          else
            #after_create :update_connected_page
            after_update :update_connected_pages
            #has_many :connectors, :conditions => 'content_block_id = #{id} and content_block_type = #{self.class} and content_block_version = #{version}', :order => "position"          
            has_many :connectors, :as => :content_block, :include => table_name, :conditions => "#{table_name}.version = connectors.content_block_version", :order => "position"          
          end
        end

        def acts_as_content_page(options={})
          acts_as_content_object(options)
        end

        private
        def acts_as_content_object(options={})
          attr_accessor :publish_on_save
          
          before_save :set_published
                    
          if options[:versioning] == false
            include NotVersionable
          else
            version_fu
            
            #We set the value of the the association to the value in the virtual attriute
            #This makes sute that updated_by_user is explictly set on each update
            versioned_class.belongs_to :updated_by, :class_name => "User"
            attr_accessor :updated_by_user, :updated_by_user_id
            belongs_to :updated_by, :class_name => "User"
            before_validation :set_updated_by
            
            validates_presence_of :updated_by_id            
            
          end
          is_paranoid

          after_destroy :destroy_versions_if_destroyed

          include InstanceMethods
        end

      end

      module NotVersionable
        #NotVersionable content objects are always published
        attr_accessor :published
        def published?
          true
        end
      end

      # These methods will be added to any object marked as acts_as_content_object or acts_as_content_page
      module InstanceMethods
        def publishable?
          if versionable?
            if new_record?
              !!connect_to_page_id              
            else
              connected_pages.count < 1
            end
          else
            false
          end
        end
        def versionable?
          self.respond_to?(:versions)
        end

        def self.included(cls)
          cls.extend ClassMethods
        end

        def status_name
          published? ? "Published" : "Draft"
        end

        def set_published
          self.published = !!(publish_on_save)
          self.publish_on_save = nil
          true
        end

        def publish(updated_by)
          self.publish_on_save = true
          self.updated_by_user = updated_by
          save          
        end

        def publish!(updated_by)
          self.publish_on_save = true
          self.updated_by_user = updated_by
          save!          
        end
        
        def live?
          versionable? ? versions.count(:conditions => ['version > ? AND published = ?', version, true]) == 0 && published? : true
        end

        def live_version
          if published?
            self
          else
            live_version = versions.first(:conditions => {:published => true}, :order => "version desc, id desc")
            live_version ? as_of_version(live_version.version) : nil
          end                
        end
        
        def draft?
          !published?
        end

        alias_method :in_progress?, :draft? 

        def destroy_versions_if_destroyed
          return unless versionable?
          self.class.versioned_class.delete_all("#{self.class.versioned_foreign_key} = #{id}") if destroyed?
        end

        def status
          published? ? :published : :draft
        end

        def set_updated_by
          if updated_by_user_id
            self.updated_by_id = updated_by_user_id
          else
            self.updated_by = updated_by_user
          end
        end

      end
    end
  end
end