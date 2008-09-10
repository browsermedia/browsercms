class HtmlBlock < ActiveRecord::Base

  acts_as_content_block
  
  def render
    content
  end
  
end