module Cms
  class ContentFilter

    # Strips HTML from any attribute that's not :content
    #
    # Handles CKEditor's habit of adding opening/closing <p> tags to everything.
    # @TODO Have this inspect the underlying model to determine the actual attribute.
    def filter(content)
      c = content.clone
      c.keys.each do |key|
        if(key != :content && key != "content")
          c[key] = HTML::FullSanitizer.new.sanitize(c[key]).strip
        end
      end
      c
    end
  end
end