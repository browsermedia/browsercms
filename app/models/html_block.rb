class HtmlBlock < ActiveRecord::Base

  acts_as_content_object
  
  def render
    content
  end
  
end