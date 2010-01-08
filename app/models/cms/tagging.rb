class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  def content_type
    ContentType.first(:conditions => {:name => taggable_type})
  end
    
end