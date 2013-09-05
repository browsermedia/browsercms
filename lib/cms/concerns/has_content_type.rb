module Cms
  module Concerns
    module HasContentType

      # Adds ContentType information to the object.
      def has_content_type
        include InstanceMethods
        extend ClassMethods
      end

      module InstanceMethods

      end

      module ClassMethods
        # Returns the Cms::ContentType which provides information about the content.
        def content_type
          Cms::ContentType.new(name: self.name)
        end

        # Allows a content block to configure which module it will be placed in.
        # @param [Symbol] module_name (Optional) Sets value if provided.
        # @return [Symbol] module_name
        def content_module(module_name=nil)
          if module_name
            @module_name = module_name
          end
          if @module_name
            @module_name
          else
            :general
          end
        end
      end
    end
  end
end