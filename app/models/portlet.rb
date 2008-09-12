class Portlet < ActiveRecord::Base

  acts_as_content_block :versioning => false
  
  belongs_to :portlet_type
  
  has_flex_attributes
  validates_presence_of :portlet_type_id, :name
  
  attr_accessor :request, :response, :params, :session
    
  class << self
    def form_partial
      "cms/#{name.tableize}/form"
    end
    def content_block_type
      "portlet"
    end  
  end
  
  def render
    portlet_type.render(self)
  end  
  
end