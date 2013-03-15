module Cms
  # An API for interacting with the Content API of BrowserCMS.
  module Content

    # Find a single content item.
    # example:
    #   Cms::Content.find("html_block", 12) # Finds a Cms::HtmlBlock with an id of 12.
    #
    # @param [String] content_name The name of the content type to find.
    # @param [Integer] id The id of the content.
    # @return [ContentBlock] A single content block or page
    def self.find(content_type, id)
      if content_type == "page"
        return Cms::Page.find(id)
      end
      type = ContentType.find_by_key(content_type)
      type.model_class.find(id)
    end

    # Find the latest draft for a single content item.
    # example:
    #   Cms::Content.find("html_block", 12) # Finds a Cms::HtmlBlock with an id of 12.
    #
    # @param [String] content_name The name of the content type to find.
    # @param [Integer] id The id of the content.
    # @return [ContentBlock] A single content block or page
    def self.find_draft(content_type, id)
      find(content_type, id).as_of_draft_version
    end
  end
end