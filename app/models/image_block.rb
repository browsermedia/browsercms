class ImageBlock < AbstractFileBlock

  acts_as_content_block

  def self.display_name
    "Image"
  end  

  def render
    #TODO: Escape values
    %Q{<img src="#{path}" alt="#{name}"/>}
  end
end
