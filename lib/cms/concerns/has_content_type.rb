module Cms
  module Concerns
    module HasContentType

      # Returns the Cms::ContentType which provides information about the content.
      def content_type
        Cms::ContentType.new(name: self.name)
      end
    end
  end
end