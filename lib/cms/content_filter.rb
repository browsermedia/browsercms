module Cms
  class ContentFilter

    # Strips HTML from any attribute that's not :content
    #
    # Handles CKEditor's habit of adding opening/closing <p> tags to everything.
    # @TODO Have this inspect the underlying model to determine the actual attribute.
    def filter(content)
      content.keys.each do |key|
        if(key != :content)
          content[key] = HTML::FullSanitizer.new.sanitize(content[key]).strip
        end
      end
      content
    end
  end
end