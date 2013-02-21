module Cms
  # An API for interacting with the Content API of BrowserCMS.
  module Content

    # Find a single content block.
    # example:
    #   Cms::Content.find("html_block", 12) # Finds a Cms::HtmlBlock with an id of 12.
    #
    # @param [String] content_name The name of the content type to find.
    # @param [Integer] id The id of the content.
    # @return [ContentBlock] A single content block
    def self.find(content_type, id)
      type = ContentType.find_by_key(content_type)
      type.model_class.find(id)
    end
  end
end