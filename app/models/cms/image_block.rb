module Cms
  class ImageBlock < Cms::AbstractFileBlock

    acts_as_content_block :belongs_to_attachment => true, :taggable => true

    def self.display_name
      "Image"
    end

  end
end