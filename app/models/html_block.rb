class HtmlBlock < ActiveRecord::Base

  acts_as_content_block
  is_paranoid
  
  def render
    content
  end

  def self.display_name
    "Html"
  end

  def self.display_name_plural
    "Html"
  end
  
end