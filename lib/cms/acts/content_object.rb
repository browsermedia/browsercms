module Cms
  module Acts
    module ContentObject
    
    def self.included(cls)
      cls.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_content_object(options={})
        include Cms::StatusSupport
      end      
    end
    end
  end
end