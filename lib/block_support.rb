module BlockSupport

  def self.included(base_class)
    base_class.send(:extend, ClassMethods)
    base_class.class_eval do
      attr_accessor :connect_to_page_id
      attr_accessor :connect_to_container
      attr_accessor :connected_page
    end
  end

  module ClassMethods
    def content_block_type
      to_s.underscore
    end
    def content_block_label
      to_s.titleize
    end
  end

  def content_block_type
    self.class.content_block_type
  end
  
  def content_block_label
    self.class.content_block_label
  end
  
  def connect_to_page
    
  end
  
end