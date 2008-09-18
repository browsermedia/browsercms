module Cms
  ###
  #
  # Any programmer defined Block's should include BlockSupport via:
  #
  # include Cms::BlockSupport
  #
  # This will grant them instance and class methods from both BlockSupport and StatusSupport
  #
  module BlockSupport
    
    def self.included(base_class)
      base_class.extend ClassMethods
      base_class.class_eval do
        attr_accessor :connect_to_page_id
        attr_accessor :connect_to_container
        attr_accessor :connected_page
        after_create :connect_to_page 
      end
    end

    module ClassMethods
      def content_block_type
        to_s.underscore
      end

      #This is needed by path helper
      #We originally didn't have this and just used respond_to(:content_block_type)
      #In order to determine if the object is a content block, 
      #but that became a problem for connector, which is not a content block,
      #but does have a content_block_type method
      def content_block?
        true
      end

      def display_name
        to_s.titleize
      end

      def display_name_plural
        display_name.pluralize
      end
    end

    # Instance Methods
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
        self.connected_page = Page.find(connect_to_page_id)
        connected_page.connectors.create(:container => connect_to_container, :content_block => self)
      end
    end
  
  end
end