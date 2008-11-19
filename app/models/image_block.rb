class ImageBlock < AbstractFileBlock
  include Attachable
  acts_as_content_block

  def self.display_name
    "Image"
  end  

  def renderer(image_block)
    lambda { %Q{<img src="#{image_block.path}" alt="#{h(image_block.name)}"/>} }    
  end
end
