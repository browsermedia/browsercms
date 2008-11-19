class HtmlBlock < ActiveRecord::Base

  acts_as_content_block
  
  def renderer(block)
    lambda { block.content }
  end

  def self.display_name
    "Text"
  end

  def self.display_name_plural
    "Text"
  end
  
end