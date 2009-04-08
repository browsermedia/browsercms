class ImageBlock < AbstractFileBlock

  acts_as_content_block :versioned => { :version_foreign_key => :file_block_id },
    :belongs_to_attachment => true, :taggable => true

  def self.display_name
    "Image"
  end  

end
