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

  # For column in list
  def portlet_type_name
    portlet_type.name
  end

  def self.template_for_new
    "cms/portlets/select_portlet_type"
  end

  def self.columns_to_list
    [{:label => "Portlet Type", :method => "portlet_type_name"}]
  end
end