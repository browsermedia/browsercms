module Cms
  module Concerns
    module HasContentType

      # Adds ContentType information to the object.
      # @param [Hash] options
      # @option options [Symbol] :module The module name, same as would be passed to content_module()
      def has_content_type(options={})
        include InstanceMethods
        extend ClassMethods

        if options[:module]
          content_module options[:module]
        end

      end

      # Used as a marker for finding classes that implement Content Types.
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