module Cms
  module Behaviors
    module Connecting

      def self.default_naming_for(klass)
        klass.name.demodulize.titleize
      end
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

          attr_accessor :connect_to_page_id, :connect_to_container,:connected_page
          attr_accessible :connect_to_page_id, :connect_to_container,:connected_page

          has_many :connectors, :as => :connectable, :class_name => 'Cms::Connector'

          attr_accessor :updated_by_page

          after_create :connect_to_page
          after_save :update_connected_pages, :unless=>:skip_callbacks


        end
      end
      module ClassMethods

        def content_block_type
          ActiveModel::Naming.singular(self)
        end
        def display_name
          Connecting.default_naming_for(self)
        end
        def display_name_plural
          display_name.pluralize
        end                
      end
      module InstanceMethods

        def connected_pages
          return @connected_pages if @connected_pages
          @connected_pages = Page.connected_to(self)
        end

        def connected_page_count
          Page.currently_connected_to(self).count
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

        #
        # After blocks are updated, all pages they are connected to should also be updated,
        # connecting the page to the new version of the block, as well as putting the pages into
        # draft status if necessary.
        #
        def update_connected_pages
          # If this is versioned, then we need make new versions of all the pages this is connected to
          if self.class.versioned?
            #logger.info "..... Updating connected pages for #{self.class} #{id} v#{version}"

            #Get all the pages the previous version of this connectable was connected to
            draft_version = draft.version
            connected_pages = Page.connected_to(:connectable => self, :version => (draft_version - 1)).all
#            puts "Found #{connected_pages}"
            connected_pages.each do |p|
              # This is needed in the case of updating page,
              # which updates this object, so as not to create a loop
              if p != updated_by_page
                #This just creates a new version of the page
                action = deleted? ? "Deleted" : "Edited"
                p.update_attributes(:version_comment => "#{self.class.name.demodulize} ##{id} was #{action}")

                #The previous step will copy over a connector pointing to the previous version of this connectable
                #We need to change that to point at the new version of this connectable
                connectors_for_page = p.connectors
#                puts "cfp #{connectors_for_page}"
                page_draft_version = p.draft.version
                cnn = connectors_for_page.for_page_version(page_draft_version)
#                puts "Connectors for page version #{page_draft_version} are #{cnn.all}"
                connectors = cnn.for_connectable(self)
#                puts "Found connectors #{connectors.all}"
                connectors.each do |con|
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
