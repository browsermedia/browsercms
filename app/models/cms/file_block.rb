module Cms
  class FileBlock < Cms::AbstractFileBlock

    acts_as_content_block :has_attachments => true, :taggable => true
    
    has_attachment :file, :url => ":attachment_file_path"
    validates_attachment_presence :file, :message => "You must upload a file"

    def self.display_name
      "File"
    end

  end
end
