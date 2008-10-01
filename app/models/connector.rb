class Connector < ActiveRecord::Base
  belongs_to :page
  
  #Can't use just 'block', because 'block_type' is used by rails
  belongs_to :content_block, :polymorphic => true

  acts_as_list :scope => 'connectors.page_id = #{page_id} and connectors.page_version = #{page_version} and connectors.container = \'#{container}\''
  alias :move_up :move_higher 
  alias :move_down :move_lower 
  
  validates_presence_of :container
  
  named_scope :for_block, lambda {|b| {:conditions => ['connectors.content_block_id = ? and connectors.content_block_type = ?', b.id, b.class.name]}}
  #named_scope :of_current_pages, {:conditions => ['connectors.page_version = pages.version'], :include => :page }
  named_scope :for_container, lambda{|container| {:conditions => ['connectors.container = ?', container]} }
  
end