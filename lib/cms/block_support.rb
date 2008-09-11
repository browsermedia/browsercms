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

      # Might be able to kill this method as duplicate of display_name ?
      def content_block_label
        to_s.titleize
      end

      def display_name
        content_block_label
      end

      def display_name_plural
        display_name.pluralize
      end
    end

    # Instance Methods
    def content_block_type
      self.class.content_block_type
    end
  
    def content_block_label
      self.class.content_block_label
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