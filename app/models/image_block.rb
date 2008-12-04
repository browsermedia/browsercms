class ImageBlock < AbstractFileBlock
  include Attachable
  acts_as_content_block :versioned => { :version_foreign_key => :file_block_id }

  def self.display_name
    "Image"
  end  

  def renderer(image_block)
    lambda { %Q{<img src="#{image_block.attachment_link}" alt="#{h(image_block.name)}"/>} }    
  end
end
