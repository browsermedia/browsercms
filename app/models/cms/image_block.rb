module Cms
  class ImageBlock < Cms::AbstractFileBlock

    acts_as_content_block :has_attachments => true, :taggable => true
    has_attachment :image, :url => ":attachment_file_path", :styles => {:thumb => "80x80"}

    def self.display_name
      "Image"
    end

  end
end
