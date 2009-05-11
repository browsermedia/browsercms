module Cms
  module Behaviors
    module Connecting
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end
      module MacroMethods
        def connectable?
          !!@is_connectable
        end
        def is_connectable(options={})
          @is_connectable = true
          extend ClassMethods
          include InstanceMethods

          attr_accessor :connect_to_page_id
          attr_accessor :connect_to_container
          attr_accessor :connected_page
        
          has_many :connectors, :as => :connectable    

          attr_accessor :updated_by_page

          after_create :connect_to_page
          after_save :update_connected_pages
        end
      end
      module ClassMethods
        def content_block_type
          to_s.underscore
        end
        def display_name
          to_s.titleize
        end
        def display_name_plural
          display_name.pluralize
        end                
      end
      module InstanceMethods

        def connected_pages
          Page.connected_to(self)
        end

        def connected_page_count
          Page.connected_to(self).count
        end

        def content_block_type
          self.class.content_block_type
        end

        def display_name
          self.class.display_name
        end

        def display_name_plural
          self.class.display_name_plural
        end
      
        def connect_to_page
          unless connect_to_page_id.blank? || connect_to_container.blank?
            #Note that we are setting connected_page so that page can look at that 
            #to determine if the page should be published            
            self.connected_page = Page.find(connect_to_page_id)
            connected_page.create_connector(self, connect_to_container)
          end
          true
        end        
      
        def update_connected_pages
          # If this is versioned, then we need make new versions of all the pages this is connected to
          if self.class.versioned? 
            #logger.info "..... Updating connected pages for #{self.class} #{id} v#{version}"

            #Get all the pages the previous version of this connectable was connected to
            draft_version = draft.version            
            Page.connected_to(:connectable => self, :version => (draft_version - 1)).all.each do |p|
              # This is needed in the case of updating page,
              # which updates this object, so as not to create a loop
              if p != updated_by_page              
                #This just creates a new version of the page
                action = deleted? ? "Deleted" : "Edited"
                p.update_attributes(:version_comment => "#{self.class.name} ##{id} was #{action}")

                #The previous step will copy over a connector pointing to the previous version of this connectable
                #We need to change that to point at the new version of this connectable
                p.connectors.for_page_version(p.draft.version).for_connectable(self).each do |con|
                  con.update_attribute(:connectable_version, draft_version)
                end
              end
            end
          end
          true
        end        
      end
    end
  end
end
