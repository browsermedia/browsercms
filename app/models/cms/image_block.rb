module Cms
  class ImageBlock < Cms::AbstractFileBlock

    acts_as_content_block :has_attachments => true, :taggable => true
    has_attachment :file, :url => ":attachment_file_path", :styles => {:thumb => "80x80"}
    validates_attachment_presence :file, :message => "You must upload a file"


    def self.display_name
      "Image"
    end

    def image
      file
    end

     # Override default behavior to handle STI class when looking up other versions of attachments.
    def attachable_type
      Cms::Attachment::FILE_BLOCKS
    end
  end
end
